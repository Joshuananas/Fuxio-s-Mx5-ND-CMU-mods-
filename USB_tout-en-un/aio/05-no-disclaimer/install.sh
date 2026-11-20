. "$(dirname "$0")/../_common.sh"
F=/jci/gui/apps/system/js/systemApp.js
modlog "install no more disclaimer"
if grep -q "_noMoreDisclaimer" "$F"; then modlog "already installed"; exit 0; fi
bak_file "$F"
sed -i 's/"displayedFunction": this._displayedDisclaimer.bind(this),/"readyFunction": this._noMoreDisclaimer.bind(this),/' "$F"
sed -i '/"noLongerDisplayedFunction": this._noLongerDisplayedDisclaimer.bind(this),/d' "$F"
sed -i '/"contextOutFunction": this._displayedDisclaimerOut.bind(this),/d' "$F"
cat >> "$F" <<'JS'

systemApp.prototype._noMoreDisclaimer = function(controlRef, appData, params) {
  framework.sendEventToMmui("system", "DisposeIntroVideo");
  this._disclaimerTime.remaining = 3500;
  framework.sendEventToMmui("common", "Global.Yes");
  framework.sendEventToMmui("system", "NotifyDisclaimerEnd");
};
JS
grep -q "_noMoreDisclaimer" "$F" || { modlog "ERROR: patch failed, restoring"; restore_file "$F"; exit 1; }
