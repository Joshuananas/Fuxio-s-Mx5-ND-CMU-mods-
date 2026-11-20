. "$(dirname "$0")/../_common.sh"
D=/jci/nativegui/images
modlog "install camera warning removal"
for f in "$D"/SafetyText_*.png; do
  [ -e "$f" ] || continue
  bak_file "$f"
done
cp -a "${MYDIR}/files/images/"*.png "$D"/
