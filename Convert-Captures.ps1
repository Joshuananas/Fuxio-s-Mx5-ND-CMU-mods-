# Converts CMU framebuffer dumps (.raw) from the capture USB to PNG + animated GIF.
# Usage: plug the capture USB, run Convert-Captures.bat
[CmdletBinding()]
param(
    [string]$Drive,            # e.g. "D:" - auto-detected if omitted
    [switch]$SwapRB,           # set if colors look wrong (red/blue swapped)
    [double]$Fps = 2           # GIF playback speed
)

Add-Type -AssemblyName System.Drawing

# ---------- Locate the capture folder ----------
$capDir = $null
if ($Drive) {
    $capDir = "$Drive\capture"
} else {
    foreach ($d in [System.IO.DriveInfo]::GetDrives()) {
        if ($d.DriveType -eq 'Removable' -and $d.IsReady) {
            $c = "$($d.Name)capture"
            if (Test-Path $c) { $capDir = $c; break }
        }
    }
}
if (-not $capDir -or -not (Test-Path $capDir)) { Write-Host "No capture/ folder found on any USB drive." -ForegroundColor Red; exit 1 }

$raws = Get-ChildItem $capDir -Filter *.raw | Sort-Object Name
if ($raws.Count -eq 0) { Write-Host "No .raw frames in $capDir" -ForegroundColor Red; exit 1 }
Write-Host "Found $($raws.Count) frame(s) in $capDir"

# ---------- Framebuffer geometry ----------
$W = 800; $H = 480; $Bpp = 0
$infoFile = Join-Path $capDir "info.txt"
if (Test-Path $infoFile) {
    $p = (Get-Content $infoFile -Raw).Trim() -split '\s+'
    if ($p[0]) { $W = [int]$p[0] }
    if ($p[1]) { $H = [int]$p[1] }
    if ($p[2]) { $Bpp = [int]$p[2] }
}
$size = $raws[0].Length
if ($Bpp -eq 0) {
    $bytesPerPx = $size / ($W * $H)
    if ($bytesPerPx -ge 3.9 -and $bytesPerPx -le 4.1) { $Bpp = 32 }
    elseif ($bytesPerPx -ge 1.9 -and $bytesPerPx -le 2.1) { $Bpp = 16 }
}
Write-Host "Geometry: ${W}x${H}, ${Bpp}bpp, frame size $size bytes"

# ---------- Decode raw -> PNG ----------
$outDir = Join-Path $PSScriptRoot "capture-out"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$pngDir = Join-Path $outDir "frames"
New-Item -ItemType Directory -Force -Path $pngDir | Out-Null
Get-ChildItem $pngDir -Filter *.png -ErrorAction SilentlyContinue | Remove-Item -Force

$fmt = if ($Bpp -eq 16) { [System.Drawing.Imaging.PixelFormat]::Format16bppRgb565 } else { [System.Drawing.Imaging.PixelFormat]::Format32bppArgb }
$srcBpp = $Bpp / 8
$srcStride = [int]($size / $H)

$i = 0
foreach ($f in $raws) {
    $i++
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    if ($SwapRB -and $Bpp -eq 32) {
        for ($k = 0; $k -lt $bytes.Length - 3; $k += 4) {
            $t = $bytes[$k]; $bytes[$k] = $bytes[$k+2]; $bytes[$k+2] = $t
        }
    }
    $bmp = New-Object System.Drawing.Bitmap($W, $H, $fmt)
    $data = $bmp.LockBits((New-Object System.Drawing.Rectangle(0,0,$W,$H)),
        [System.Drawing.Imaging.ImageLockMode]::WriteOnly, $fmt)
    $dstStride = $data.Stride
    for ($y = 0; $y -lt $H; $y++) {
        $rowBytes = [Math]::Min($srcStride, [Math]::Abs($dstStride))
        [System.Runtime.InteropServices.Marshal]::Copy($bytes, $y * $srcStride,
            [IntPtr]($data.Scan0.ToInt64() + $y * $dstStride), $rowBytes)
    }
    $bmp.UnlockBits($data)
    $png = Join-Path $pngDir ("f{0:D3}.png" -f $i)
    $bmp.Save($png, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Progress -Activity "Decoding frames" -Status $f.Name -PercentComplete (100*$i/$raws.Count)
}
Write-Progress -Activity "Decoding frames" -Completed
Write-Host "PNGs -> $pngDir" -ForegroundColor Green

# ---------- Assemble GIF with ffmpeg ----------
$ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
if (-not $ffmpeg) {
    Write-Host "ffmpeg not found - PNG frames are in $pngDir (assemble them into a GIF manually)" -ForegroundColor Yellow
    exit 0
}
$gif = Join-Path $outDir "cmu-capture.gif"
$vf = "fps=$Fps,scale=800:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=256[p];[s1][p]paletteuse=dither=bayer"
& ffmpeg -y -loglevel error -framerate $Fps -i (Join-Path $pngDir "f%03d.png") -vf $vf $gif
if (Test-Path $gif) {
    Write-Host "GIF -> $gif" -ForegroundColor Green
    $dest = Join-Path $PSScriptRoot "images\cmu-capture.gif"
    Copy-Item $gif $dest -Force
    Write-Host "Copied to $dest (usable in the tool preview)" -ForegroundColor Green
    Invoke-Item $outDir
} else {
    Write-Host "GIF creation failed - PNG frames available in $pngDir" -ForegroundColor Yellow
}
