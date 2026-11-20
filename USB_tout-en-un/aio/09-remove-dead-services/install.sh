. "$(dirname "$0")/../_common.sh"
# Disable dead/NA-only services: Aha, Stitcher, Pandora, internet-radio
# streaming servers and SiriusXM. All are autorun entries in /jci/sm/sm.conf.
# Services this firmware does not define are silently skipped.
# Reversible: the exact changes are recorded in $STATE, reverted by uninstall.sh.
F=/jci/sm/sm.conf
STATE="${BACKUP_ROOT}/09-remove-dead-services"
modlog "disable dead services (aha/stitcher/pandora/siriusxm)"

bak_file "$F"
mkdir -p "${BACKUP_ROOT}"
: > "$STATE.services"
: > "$STATE.aha_lines"

# --- Aha: 3 boot stages wait on blm_ira_aha; re-point them at stage_ir first,
#     otherwise disabling it stalls voice/warnings/Wi-Fi (OpenCMU findings).
#     Record "lineno<TAB>original_line" for surgical revert.
grep -n 'value="blm_ira_aha"' "$F" > "$STATE.aha_lines" 2>/dev/null || true
if [ -s "$STATE.aha_lines" ]
then
  sed -i 's/value="blm_ira_aha"/value="stage_ir"/g' "$F"
  modlog "re-pointed $(wc -l < "$STATE.aha_lines") aha boot stage(s) to stage_ir"
fi

# --- Set autorun="no" inside each named <service> block ---
for svc in blm_ira_aha blm_ira_pandora blm_ira_stitcher \
           irs_server irsstitcher_server \
           jciSXMS jciXMMGR jciXMDATA jcixmad jcixm
do
  # Does this service block exist and contain autorun="yes"?
  awk -v s="$svc" '
    index($0,"<service ") && index($0,"name=\"" s "\"") {inb=1}
    inb && index($0,"autorun=\"yes\"") {found=1; exit}
    index($0,"</service>") {inb=0}
    END {exit !found}' "$F" || continue

  awk -v s="$svc" '
    index($0,"<service ") && index($0,"name=\"" s "\"") {inb=1}
    inb {gsub(/autorun="yes"/,"autorun=\"no\"")}
    index($0,"</service>") {inb=0}
    {print}' "$F" > "$F.new" && mv "$F.new" "$F"

  echo "$svc" >> "$STATE.services"
  modlog "disabled $svc"
done

# --- Remove the dead entries from the source-selection menu ---
# Disabling the services stops the processes, but the menu entries are built
# by systemApp._buildEntertainmentDataList in systemApp.js. Append a guarded
# wrapper that filters the dead audioSourceIds out of the list.
JS=/jci/gui/apps/system/js/systemApp.js
if [ -f "$JS" ] && ! grep -q '__aio9_srcfilter' "$JS"
then
  bak_file "$JS"
  cat >> "$JS" <<'EOF'

/* __aio9_srcfilter: drop dead sources (Aha/Stitcher/Pandora/SiriusXM) from the
 * entertainment source list. Wraps the stock list builder and filters
 * dataList.items by appData.audioSourceId. Never selects a source. */
(function () {
    if (typeof systemApp === "undefined" || !systemApp.prototype) return;
    if (systemApp.prototype.__aio9SrcFilterWrapped) return;
    if (typeof systemApp.prototype._buildEntertainmentDataList !== "function") return;
    systemApp.prototype.__aio9SrcFilterWrapped = true;
    var dead = {AhaRadio:1, Stitcher:1, Pandora:1, XmAudio:1, SatRadio:1};
    var buildDataList = systemApp.prototype._buildEntertainmentDataList;
    systemApp.prototype._buildEntertainmentDataList = function () {
        var dataList = buildDataList.apply(this, arguments);
        if (!dataList || !dataList.items) return dataList;
        var kept = [];
        for (var i = 0; i < dataList.items.length; i++) {
            var it = dataList.items[i];
            if (!(it && it.appData && dead[it.appData.audioSourceId])) kept.push(it);
        }
        dataList.items = kept;
        dataList.itemCount = kept.length;
        return dataList;
    };
})();
EOF
  if grep -q '__aio9_srcfilter' "$JS"
  then modlog "filtered dead sources from source menu"
  else modlog "WARN: source menu patch failed"; restore_file "$JS"; fi
fi

sync
modlog "done"
