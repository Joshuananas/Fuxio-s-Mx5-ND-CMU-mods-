# Shared helpers for AIO-derived modules. Sourced by each install/uninstall.
BACKUP_ROOT=/data_persist/allinone-backups

bak_file() {
  dst="${BACKUP_ROOT}$1"
  mkdir -p "$(dirname "$dst")"
  [ -e "$dst" ] || cp -a "$1" "$dst"
}
restore_file() {
  src="${BACKUP_ROOT}$1"
  if [ -e "$src" ]; then cp -a "$src" "$1" && rm -f "$src"; return 0; fi
  return 1
}
modlog() { echo "[$(basename "$(dirname "$0")")] $1"; }
