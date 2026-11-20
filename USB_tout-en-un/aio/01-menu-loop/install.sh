. "$(dirname "$0")/../_common.sh"
F=/jci/gui/apps/system/controls/MainMenu/js/MainMenuCtrl.js
modlog "install main menu loop"
bak_file "$F"
cp -a "${MYDIR}/files/MainMenuCtrl.js" "$F"
