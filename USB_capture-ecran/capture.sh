#!/bin/sh
# Screen capture tool for Mazda CMU — dumps /dev/fb0 frames to the USB drive.
# Convert the .raw frames to PNG/GIF on the PC with Convertir-captures.bat.

hwclock --hctosys

echo 1 > /sys/class/gpio/Watchdog\ Disable/value
mount -o rw,remount /

MYDIR=$(dirname "$(readlink -f "$0")")
mount -o rw,remount ${MYDIR}

CAPDIR="${MYDIR}/capture"
mkdir -p "${CAPDIR}"

# --- Translations (ASCII only for the CMU display) ---
T() {
  case "${LANG_CODE}" in
    fr) eval "echo \"\$FR_$1\"" ;;
    de) eval "echo \"\$DE_$1\"" ;;
    es) eval "echo \"\$ES_$1\"" ;;
    zh) eval "echo \"\$ZH_$1\"" ;;
    *)  eval "echo \"\$EN_$1\"" ;;
  esac
}

EN_menu="Screen capture tool\n\nPhoto = one screenshot\nVideo = records the screen while you navigate\n\nChoose an action:"
FR_menu="Outil de capture d'ecran\n\nPhoto = une capture\nVideo = enregistre l'ecran pendant que vous naviguez\n\nChoisissez une action :"
DE_menu="Bildschirm-Aufnahme\n\nFoto = ein Screenshot\nVideo = zeichnet den Bildschirm auf waehrend Sie navigieren\n\nAktion waehlen:"

EN_photo="Photo";         FR_photo="Photo";          DE_photo="Foto"
EN_video="Video";         FR_video="Video";          DE_video="Video"
EN_quit="Quit";           FR_quit="Quitter";         DE_quit="Beenden"
EN_back="Back";           FR_back="Retour";          DE_back="Zurueck"
EN_dur="Video duration?"; FR_dur="Duree de la video ?"; DE_dur="Video-Dauer?"
EN_rec="Recording the screen for %s s.\nNavigate normally in the menus.\nDo NOT remove the USB drive."
FR_rec="Enregistrement de l'ecran pendant %s s.\nNaviguez normalement dans les menus.\nNe retirez PAS la cle USB."
DE_rec="Bildschirm wird %s s aufgezeichnet.\nNormal in den Menues navigieren.\nUSB-Stick NICHT entfernen."
EN_done="Done! %s frame(s) saved to:\ncapture/ on the USB drive\n\nRemove the USB drive and run\nConvertir-captures.bat on the PC."
FR_done="Termine ! %s image(s) dans :\ncapture/ sur la cle USB\n\nRetirez la cle et lancez\nConvertir-captures.bat sur le PC."
DE_done="Fertig! %s Bild(er) gespeichert in:\ncapture/ auf dem USB-Stick\n\nStick entfernen und Convertir-captures.bat\nauf dem PC starten."
EN_saving="Saving photo..."; FR_saving="Enregistrement de la photo..."; DE_saving="Foto wird gespeichert..."
EN_fb="ERROR: /dev/fb0 not readable."; FR_fb="ERREUR : /dev/fb0 illisible."; DE_fb="FEHLER: /dev/fb0 nicht lesbar."

ES_menu="Herramienta de captura

Foto = una captura
Video = graba la pantalla mientras navegas

Elige una accion:"; ZH_menu="屏幕截图工具。照片 = 一张屏幕截图。视频 = 在您导航时记录屏幕。选择一个动作：";
ES_photo="Foto"; ZH_photo="照片";
ES_video="Video"; ZH_video="视频";
ES_quit="Salir"; ZH_quit="关闭";
ES_back="Volver"; ZH_back="返回";
ES_dur="Duracion del video?"; ZH_dur="视频时长？";
ES_rec="Grabando la pantalla durante %s s.
Navega normalmente por los menus.
No retires la unidad USB."; ZH_rec="录制屏幕 %s 秒。在菜单中正常导航。请勿移除 USB 驱动器。";
ES_done="Terminado! %s imagen(es) en:
capture/ en la USB

Retira la USB y ejecuta
Convertir-captures.bat en el PC."; ZH_done="完毕！ %s 帧保存到：捕获/USB 驱动器上。拔下 USB 驱动器并在 PC 上运行 Convertir-captures.bat。";
ES_saving="Guardando foto..."; ZH_saving="正在保存照片...";
ES_fb="ERROR: /dev/fb0 no legible."; ZH_fb="错误：/dev/fb0 不可读。";

# --- Language picker ---
/jci/tools/jci-dialog --3-button-dialog   --title="Language / Langue"   --text="Select language / Choisir la langue"   --ok-label="English"   --cancel-label="Francais"   --button3-label="More..."
case $? in
  0) LANG_CODE=en ;;
  1) LANG_CODE=fr ;;
  *)
    /jci/tools/jci-dialog --3-button-dialog       --title="Language / Idioma"       --text="Select / Elegir"       --ok-label="Deutsch"       --cancel-label="Espanol"       --button3-label="Chinese"
    case $? in
      0) LANG_CODE=de ;;
      1) LANG_CODE=es ;;
      2) LANG_CODE=zh ;;
      *) LANG_CODE=en ;;
    esac ;;
esac

if [ ! -r /dev/fb0 ]
then
  /jci/tools/jci-dialog --info --title="Screen capture" \
    --text="$(T fb)" --no-cancel &
  sleep 5
  killall -q jci-dialog
  exit 1
fi

# Save framebuffer geometry so the PC converter can decode the raw frames
FBX=$(cat /sys/class/graphics/fb0/virtual_size 2>/dev/null | cut -d, -f1)
FBY=$(cat /sys/class/graphics/fb0/virtual_size 2>/dev/null | cut -d, -f2)
FBBPP=$(cat /sys/class/graphics/fb0/bits_per_pixel 2>/dev/null)
echo "${FBX} ${FBY} ${FBBPP}" > "${CAPDIR}/info.txt"

grab_frame() { cat /dev/fb0 > "${CAPDIR}/$1"; }

record() {  # $1 = seconds
  _secs=$1
  _txt=$(T rec)
  _txt=$(printf "${_txt}" "${_secs}")
  /jci/tools/jci-dialog --info --title="Screen capture" \
    --text="${_txt}\n\n3... 2... 1..." --no-cancel &
  sleep 3
  killall -q jci-dialog        # dialog must be gone: it would hide the real screen
  _end=$(( $(date +%s) + _secs ))
  _n=0
  while [ "$(date +%s)" -lt "${_end}" ]
  do
    _n=$(( _n + 1 ))
    grab_frame "$(printf 'f%03d.raw' ${_n})"
  done
  _dt=$(T done)
  /jci/tools/jci-dialog --info --title="Screen capture" \
    --text="$(printf "${_dt}" "${_n}")" --no-cancel &
  sleep 6
  killall -q jci-dialog
}

while true
do
  /jci/tools/jci-dialog --3-button-dialog \
    --title="Screen capture" \
    --text="$(T menu)" \
    --ok-label="$(T photo)" \
    --cancel-label="$(T video)" \
    --button3-label="$(T quit)"
  _m=$?

  case ${_m} in
    0)  # Photo
        /jci/tools/jci-dialog --info --title="Screen capture" \
          --text="$(T saving)" --no-cancel &
        sleep 1
        killall -q jci-dialog
        grab_frame "shot_$(date +%H%M%S).raw"
        _dt=$(T done)
        /jci/tools/jci-dialog --info --title="Screen capture" \
          --text="$(printf "${_dt}" "1")" --no-cancel &
        sleep 5
        killall -q jci-dialog
        ;;
    1)  # Video -> duration
        /jci/tools/jci-dialog --3-button-dialog \
          --title="Screen capture" \
          --text="$(T dur)" \
          --ok-label="30 s" \
          --cancel-label="60 s" \
          --button3-label="$(T back)"
        _d=$?
        case ${_d} in
          0) record 30 ;;
          1) record 60 ;;
        esac
        ;;
    *)  exit 0 ;;
  esac
done
