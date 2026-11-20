. "$(dirname "$0")/../_common.sh"
for f in /jci/nativegui/images/SafetyText_*.png; do
  [ -e "$f" ] || continue
  restore_file "$f"
done
