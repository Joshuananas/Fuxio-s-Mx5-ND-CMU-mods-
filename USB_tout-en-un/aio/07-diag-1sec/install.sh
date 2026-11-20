. "$(dirname "$0")/../_common.sh"
F1=/jci/gui/apps/diag/js/diagApp.js
F2=/jci/gui/common/controls/StatusBar/js/StatusBarCtrl.js
F3=/jci/gui/common/js/Common.js
modlog "install 1sec diag menu"
bak_file "$F1"; bak_file "$F2"; bak_file "$F3"
sed -i 's/"settleTime" : 20000,/"settleTime" : 1000,/g' "$F1"
sed -i 's/"holdTimeout" : 5000,/"holdTimeout" : 1000,/g' "$F2"
if ! grep -Fq 'framework.sendEventToMmui("syssettings", "SelectDiagnostics"); // Sumire Racing' "$F3"; then
  sed -i '/this._diagEntrySequence = 1;/ a\framework.sendEventToMmui("syssettings", "SelectDiagnostics"); // Sumire Racing' "$F3"
fi
for f in /jci/gui/apps/diag/controls/Test/js/TestCtrl.js /jci/gui/apps/diag/controls/Test/css/TestCtrl.css; do
  [ -e "$f" ] && bak_file "$f"
done
cp -a "${MYDIR}/files/controls" /jci/gui/apps/diag
