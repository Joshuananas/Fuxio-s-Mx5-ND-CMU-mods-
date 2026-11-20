. "$(dirname "$0")/../_common.sh"
# Surgical revert of 09-remove-dead-services. Works on the CURRENT sm.conf
# whatever its state (oem-aa-mod may already have restored the stock file,
# in which case every pattern below is a no-op).
F=/jci/sm/sm.conf
STATE="${BACKUP_ROOT}/09-remove-dead-services"
modlog "re-enable dead services"

had_state=0
[ -f "$STATE.services" ] && had_state=1
[ -f "$STATE.aha_lines" ] && had_state=1

if [ -f "$STATE.services" ]
then
  while read svc
  do
    awk -v s="$svc" '
      index($0,"<service ") && index($0,"name=\"" s "\"") {inb=1}
      inb {gsub(/autorun="no"/,"autorun=\"yes\"")}
      index($0,"</service>") {inb=0}
      {print}' "$F" > "$F.new" && mv "$F.new" "$F"
    modlog "re-enabled $svc"
  done < "$STATE.services"
  rm -f "$STATE.services"
fi

# Aha boot stages: put back blm_ira_aha at the recorded line numbers
# (grep -n output format is "lineno:line"). Only revert a line that still
# says stage_ir — otherwise it is already back to stock.
if [ -s "$STATE.aha_lines" ]
then
  while read entry
  do
    ln=${entry%%:*}
    sed -n "${ln}p" "$F" | grep -q 'value="stage_ir"' || continue
    sed -i "${ln}s/value=\"stage_ir\"/value=\"blm_ira_aha\"/" "$F"
    modlog "restored aha stage at line $ln"
  done < "$STATE.aha_lines"
  rm -f "$STATE.aha_lines"
fi

# Fallback only if nothing was recorded at all (state files absent):
# restore the whole-file backup made at install time.
if [ $had_state -eq 0 ]
then
  restore_file "$F" && modlog "restored sm.conf from backup"
fi

sync
modlog "done"
