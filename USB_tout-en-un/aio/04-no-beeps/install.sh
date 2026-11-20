. "$(dirname "$0")/../_common.sh"
F1=/jci/gui/common/js/Common.js
F2=/jci/gui/common/controls/List2/js/List2Ctrl.js
modlog "install no beeps"
bak_file "$F1"; bak_file "$F2"
sed -i "s/    this._beep('Long', 'Multicontroller');/\/\/  this._beep('Long', 'Multicontroller');/g" "$F2"
if grep -Fq "No More Beeps" "$F1"; then
  :
elif grep -Fq '    framework.sendEventToMmui("system", "PlayAudioBeep", args);' "$F1"; then
  sed -i 's/    framework.sendEventToMmui("system", "PlayAudioBeep", args);/    \/\/ framework.sendEventToMmui("system", "PlayAudioBeep", args); \/\/ No More Beeps/g' "$F1"
elif grep -Fq '    framework.sendEventToMmui("audiosettings", "PlayAudioBeep", args);' "$F1"; then
  sed -i 's/    framework.sendEventToMmui("audiosettings", "PlayAudioBeep", args);/    \/\/ framework.sendEventToMmui("audiosettings", "PlayAudioBeep", args); \/\/ No More Beeps/g' "$F1"
fi
