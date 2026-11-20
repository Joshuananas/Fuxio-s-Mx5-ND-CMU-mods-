# MX-5 ND CMU Mods — All-in-One USB Installer

A safe, reversible, multilingual USB workflow to customize the **Mazda Connect (CMU)** infotainment system of the **Mazda MX-5 ND** — and other Gen 6 Mazda Connect vehicles.

> ⚠️ **Supported firmware: `74.00.324` / `74.00.324A` only.** The installer checks `/jci/version.ini` and refuses to run on anything else. Check your version in *Settings → System → About* before use.

---

## What it does

Everything is prepared on your PC with a friendly GUI, written to a plain **FAT32 USB stick**, and applied in the car through a translated on-screen menu — no laptop needed at the car.

### Included mods

| Module | What it does |
|---|---|
| **oem-aa-mod** | Better Android Auto: DPI/scaling fixes, touchscreen input, HUD navigation, audio latency, optional wireless-adapter support |
| **TouchTune** | Touchscreen use while driving |
| **Menu & list looping** | Menus and lists wrap around at the ends |
| **Shorter delays** | Snappier list scrolling |
| **No beeps** | Silences UI beeps |
| **No startup disclaimer** | Auto-acknowledges the "don't use while driving" screen |
| **No camera warning** | Removes the reverse-camera warning text |
| **1-second diagnostics** | Faster access to the diagnostic menu |
| **Bigger album art** | Larger artwork on the now-playing screen |
| **Remove dead services** | Disables Aha, Stitcher, Pandora, internet-radio servers and SiriusXM — stops the services *and* removes them from the source menu (~65 MB RAM freed, faster boot) |

### Safety first

- ✅ **Firmware-gated** — won't run on unsupported versions
- ✅ **Fully reversible** — every change is backed up and can be uninstalled from the same menu
- ✅ **One `.up` launcher** — the tool detects and prevents duplicate launchers
- ✅ **Per-module progress** on the car's screen, translated, non-blocking
- ✅ Confirmation dialogs before anything is written

### Languages

English 🇬🇧 · Français 🇫🇷 · Deutsch 🇩🇪 · Español 🇪🇸 · 中文 🇨🇳
*(CMU dialogs may lack CJK glyphs — Chinese menus might show as boxes depending on region.)*

---

## Usage

### 1. Prepare the key (PC)

Run **`Preparer-cle-CMU.bat`**, choose *installation key*, pick your USB drive (FAT32, MBR), tick the mods you want, pick the language, click **Write**.

### 2. Install in the car

Plug the stick into the car's USB port, wait ~60 s, choose the language → **Install** → confirm → wait for the completion message → reboot.

### 3. Uninstall

Same key → **Uninstall**. All backups are restored and every mod is reverted.

---

## Bonus: CMU screen-capture key

A second package (`USB_capture-ecran/`) turns a spare USB stick into a **screen recorder**: it dumps the framebuffer while you navigate the menus, then `Convertir-captures.bat` on the PC converts the raw frames into PNGs and an **animated GIF** — perfect for previews and documentation.

---

## Project layout

```
Preparer-cle-CMU.bat/.ps1   PC GUI (WPF): prepares install or capture keys
USB_tout-en-un/             Install package (run.sh, aio/ modules, oem-aa-mod, touchtune)
USB_capture-ecran/          Framebuffer capture package (capture.sh)
Convertir-captures.bat/.ps1 Raw frames → PNG + animated GIF
images/                     Preview assets & flags for the GUI
```

## Credits

Built on the shoulders of the community:

- [oem-aa-mod](https://github.com/VitaliyKurokhtin/oem-aa-mod) — Android Auto shims
- [TouchTune](https://github.com/Miatafy/TouchTune) — touch-while-driving
- [OpenCMU](https://github.com/nidr0x/OpenCMU) — service-disable & source-list techniques
- [MZD-AIO / mazdatweaks.com](https://www.mazdatweaks.com/) — the classic tweak collection

## Disclaimer

This is a community project, not affiliated with Mazda. Modifying your CMU is done **at your own risk** — a wrong move can brick the unit. Everything here is designed to be reversible and firmware-gated, but read the code and understand what you're flashing. Your warranty is your own business.

---

## ☕ Support the project

Free and open-source, built on weekends for the ND community. If this pack made your drives better, a coffee keeps it alive and updated for new firmware:

**[ko-fi.com/fuxio11](https://ko-fi.com/fuxio11)** — thank you, and drive safe! 🏎️

---

### 🇫🇷 En bref

Pack tout-en-un pour personnaliser le système Mazda Connect de la MX-5 ND (firmware **74.00.324** uniquement) : meilleur Android Auto, tactile en roulant, disparition de l'écran d'avertissement, suppression d'Aha/Stitcher/Pandora/SiriusXM, et plus — le tout **réversible**, **multilingue** et préparé via une interface graphique Windows sur une simple clé USB FAT32. **Utilisez-le à vos risques et périls.**
