. "$(dirname "$0")/../_common.sh"
# Auto-acknowledge the boot disclaimer. Stock 74.00.324 binds the Disclaimer
# template's displayedFunction to _displayedDisclaimer; re-point it at our
# handler which disposes the intro video and sends NotifyDisclaimerEnd.
F=/jci/gui/apps/system/js/systemApp.js
modlog "install no more disclaimer"

# Detect the real spelling: stock uses '"displayedFunction" :' (space before
# the colon); some dumps are minified without the space. Try both.
if grep -q '"displayedFunction" *: *this\._displayedDisclaimer\.bind(this)' "$F"
then
  grep -q 'this\._noMoreDisclaimer\.bind(this)' "$F" && { modlog "already installed"; exit 0; }
  bak_file "$F"
  sed -i 's/"displayedFunction" *: *this\._displayedDisclaimer\.bind(this)/"displayedFunction" : this._noMoreDisclaimer.bind(this)/' "$F"
  grep -q 'this\._noMoreDisclaimer\.bind(this)' "$F" \
    || { modlog "ERROR: rebind failed, restoring"; restore_file "$F"; exit 1; }
else
  modlog "WARN: disclaimer binding not found in systemApp.js - skipping"
  exit 0
fi

# The handler: only append if the file does not define it yet.
grep -q '_noMoreDisclaimer = function' "$F" || cat >> "$F" <<'JS'

systemApp.prototype._noMoreDisclaimer = function(controlRef, appData, params) {
  framework.sendEventToMmui("system", "DisposeIntroVideo");
  this._disclaimerTime.remaining = 3500;
  framework.sendEventToMmui("common", "Global.Yes");
  framework.sendEventToMmui("system", "NotifyDisclaimerEnd");
};
JS
grep -q '_noMoreDisclaimer = function' "$F" || { modlog "ERROR: handler append failed, restoring"; restore_file "$F"; exit 1; }
modlog "disclaimer auto-acknowledged"
