. "$(dirname "$0")/../_common.sh"
F=/jci/gui/common/controls/List2/js/List2Ctrl.js
modlog "install list loop"
bak_file "$F"
cp -a "${MYDIR}/files/List2Ctrl.js" "$F"
