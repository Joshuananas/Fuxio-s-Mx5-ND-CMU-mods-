#!/bin/sh
# All-in-one installer for Mazda CMU — modules gated by MODS.cfg
# oem-aa-mod : https://github.com/VitaliyKurokhtin/oem-aa-mod (installer by Bijan-A)
# TouchTune  : https://github.com/Miatafy/TouchTune

hwclock --hctosys

echo 1 > /sys/class/gpio/Watchdog\ Disable/value
mount -o rw,remount /

MYDIR=$(dirname "$(readlink -f "$0")")
mount -o rw,remount ${MYDIR}

# --- Module flags (defaults: everything on if MODS.cfg is absent) ---
MOD_OEM_AA=1
MOD_TOUCHTUNE=1
if [ -f "${MYDIR}/MODS.cfg" ]
then
  # Strip CR in case the file was written with Windows line endings
  sed 's/\r$//' "${MYDIR}/MODS.cfg" > /tmp/MODS.cfg
  . /tmp/MODS.cfg
fi
[ -d "${MYDIR}/touchtune" ] || MOD_TOUCHTUNE=0

# AIO module flag helper: flag name = MOD_AIO_<folder uppercase, - -> _>
# Default for each module is ON unless MODS.cfg sets it to 0.
aio_mod_enabled() {
  _base=$(basename "$1" | tr 'a-z-' 'A-Z_')
  eval "_v=\${MOD_AIO_${_base}:-1}"
  [ "${_v}" = "1" ]
}

# UI language early: from MODS.cfg (written by the PC tool), English default
LANG_CODE=${LANG:-en}
case "${LANG_CODE}" in en|fr|de|es|zh) ;; *) LANG_CODE=en ;; esac

# --- Require CMU firmware V74.00.324 ---
get_cmu_ver()
{
  _ver=$(grep '^JCI_SW_VER=' /jci/version.ini | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
  echo ${_ver}
}

CMU_VER=$(get_cmu_ver)
if [ "${CMU_VER}" != "74.00.324" ]
then
  case "${LANG_CODE}" in
    fr) _fwtxt="Cet installeur ne supporte que le firmware CMU V74.00.324.\nVersion detectee : V${CMU_VER}\nInstallation annulee.\nRetirez la cle USB.\nRedemarrage dans 5 secondes..." ;;
    de) _fwtxt="Dieser Installer unterstuetzt nur CMU-Firmware V74.00.324.\nErkannte Version: V${CMU_VER}\nInstallation abgebrochen.\nUSB-Stick entfernen.\nNeustart in 5 Sekunden..." ;;
    *)  _fwtxt="This installer only supports CMU firmware V74.00.324.\nDetected version: V${CMU_VER}\nInstallation aborted.\nRemove USB drive.\nRebooting in 5 seconds..." ;;
  esac
  /jci/tools/jci-dialog --info --title="All-in-one mods" \
    --text="${_fwtxt}" \
    --no-cancel &
  sleep 5
  killall -q jci-dialog
  exit 1
fi

mkdir -p "${MYDIR}/logs"

_mods_text=""
[ "${MOD_OEM_AA}" = "1" ] && _mods_text="oem-aa-mod"
[ "${MOD_TOUCHTUNE}" = "1" ] && _mods_text="${_mods_text}${_mods_text:+ + }TouchTune"
for _m in "${MYDIR}"/aio/*/; do
  aio_mod_enabled "${_m}" && _mods_text="${_mods_text}${_mods_text:+ + }$(basename "${_m}")"
done
[ -z "${_mods_text}" ] && _mods_text="(none selected)"

# ============================================================
# Language selection + main menu (loops until Install/Uninstall)
# ============================================================
# (LANG_CODE already initialised above, before the firmware check)
T() {
  case "${LANG_CODE}:$1" in
    fr:menu)      echo "Modules : ${_mods_text}\nQue voulez-vous faire ?" ;;
    fr:install)   echo "Installation en cours...\nNe retirez pas la cle USB." ;;
    fr:uninstall) echo "Desinstallation en cours...\nNe retirez pas la cle USB." ;;
    fr:done)      echo "Installation terminee !\nVous pouvez retirer la cle.\nRedemarrage dans 5 secondes..." ;;
    fr:cancelled) echo "Annule.\nRien n'a ete modifie.\nVous pouvez retirer la cle." ;;
    de:menu)      echo "Module: ${_mods_text}\nWas moechten Sie tun?" ;;
    de:install)   echo "Installation laeuft...\nUSB-Stick nicht entfernen." ;;
    de:uninstall) echo "Deinstallation laeuft...\nUSB-Stick nicht entfernen." ;;
    de:done)      echo "Installation abgeschlossen!\nUSB-Stick kann entfernt werden.\nNeustart in 5 Sekunden..." ;;
    de:cancelled) echo "Abgebrochen.\nNichts wurde geaendert.\nUSB-Stick kann entfernt werden." ;;
    en:menu)      echo "Modules: ${_mods_text}\nWhat would you like to do?" ;;
    en:install)   echo "Installing mods...\nDo not remove USB drive." ;;
    en:uninstall) echo "Uninstalling mods...\nDo not remove USB drive." ;;
    en:done)      echo "Installation complete!\nYou can remove the USB drive.\nRebooting in 5 seconds..." ;;
    en:cancelled) echo "Cancelled.\nNothing was changed.\nYou can remove the USB drive." ;;
    fr:sum_i)     echo "Installation terminee !\nVous pouvez retirer la cle.\n\nSi ce pack vous est utile :\nko-fi.com/fuxio11" ;;
    fr:sum_u)     echo "Desinstallation terminee !\nVous pouvez retirer la cle.\n\nSi ce pack vous est utile :\nko-fi.com/fuxio11" ;;
    fr:reboot30)  echo "\nRedemarrage automatique dans 30 s.\nAppuyez sur Redemarrer pour le faire maintenant." ;;
    de:sum_i)     echo "Installation abgeschlossen!\nUSB-Stick kann entfernt werden.\n\nNuetzlich? Unterstuetzen:\nko-fi.com/fuxio11" ;;
    de:sum_u)     echo "Deinstallation abgeschlossen!\nUSB-Stick kann entfernt werden.\n\nNuetzlich? Unterstuetzen:\nko-fi.com/fuxio11" ;;
    de:reboot30)  echo "\nAutomatischer Neustart in 30 s.\n'Neustart' druecken fuer sofortigen Neustart." ;;
    en:sum_i)     echo "Installation complete!\nYou can remove the USB drive.\n\nIf this pack helped you:\nko-fi.com/fuxio11" ;;
    en:sum_u)     echo "Uninstall complete!\nYou can remove the USB drive.\n\nIf this pack helped you:\nko-fi.com/fuxio11" ;;
    en:reboot30)  echo "\nAutomatic reboot in 30 s.\nPress Restart to reboot now." ;;
    fr:ttskip)    echo "\nATTENTION: TouchTune ignore — Common.js modifie par un autre outil." ;;
    de:ttskip)    echo "\nACHTUNG: TouchTune uebersprungen — Common.js von anderem Tool geaendert." ;;
    de:ttfix)     echo "Common.js gepatcht: Wiederherstellung vor TouchTune" ;;
    en:ttskip)    echo "\nWARNING: TouchTune skipped — Common.js changed by another tool." ;;
    fr:ttfix)     echo "Common.js patche: restauration avant TouchTune" ;;
    en:ttfix)     echo "Common.js patched: restoring before TouchTune" ;;
    fr:conf_i)    echo "Continuer l'installation ?\nModules : ${_mods_text}" ;;
    fr:conf_u)    echo "Continuer la desinstallation ?\nModules : ${_mods_text}" ;;
    fr:quitm)     echo "Quitter sans rien modifier ?" ;;
    fr:prog_i)    echo "Installation en cours :\n%s\n\nNe retirez pas la cle USB." ;;
    fr:prog_u)    echo "Desinstallation en cours :\n%s\n\nNe retirez pas la cle USB." ;;
    de:prog_i)    echo "Installation laeuft :\n%s\n\nUSB-Stick nicht entfernen." ;;
    de:prog_u)    echo "Deinstallation laeuft :\n%s\n\nUSB-Stick nicht entfernen." ;;
    es:prog_i)    echo "Instalando :\n%s\n\nNo retire la unidad USB." ;;
    es:prog_u)    echo "Desinstalando :\n%s\n\nNo retire la unidad USB." ;;
    en:prog_i)    echo "Installing :\n%s\n\nDo not remove the USB drive." ;;
    en:prog_u)    echo "Uninstalling :\n%s\n\nDo not remove the USB drive." ;;
    zh:prog_i)    echo "安装中 :\n%s\n\n请勿移除 USB 驱动器." ;;
    zh:prog_u)    echo "卸载 :\n%s\n\n请勿移除 USB 驱动器." ;;
    de:conf_i)    echo "Installation fortsetzen?\nModule: ${_mods_text}" ;;
    de:conf_u)    echo "Deinstallation fortsetzen?\nModule: ${_mods_text}" ;;
    de:quitm)     echo "Beenden ohne Aenderungen?" ;;
    en:conf_i)    echo "Continue installation?\nModules: ${_mods_text}" ;;
    en:conf_u)    echo "Continue uninstall?\nModules: ${_mods_text}" ;;
    en:quitm)     echo "Quit without changing anything?" ;;
    es:menu)      echo "Modulos: ${_mods_text}
Que desea hacer?" ;;
    zh:menu)      echo "模块。你想做什么？
${_mods_text}" ;;
    es:install)   echo "Instalando mods...
No retire la unidad USB." ;;
    zh:install)   echo "安装模组。请勿移除 USB 驱动器。" ;;
    es:uninstall) echo "Desinstalando mods...
No retire la unidad USB." ;;
    zh:uninstall) echo "卸载模组。请勿移除 USB 驱动器。" ;;
    es:done)      echo "Instalacion terminada!
Puede retirar la USB.
Reinicio en 5 segundos..." ;;
    zh:done)      echo "安装完成。您可以移除 USB 驱动器。 5秒后重启。" ;;
    es:cancelled) echo "Cancelado.
No se modifico nada.
Puede retirar la USB." ;;
    zh:cancelled) echo "取消。一切都没有改变。您可以移除 USB 驱动器。" ;;
    es:sum_i)     echo "Instalacion terminada!
Puede retirar la USB.

Si te sirvio:
ko-fi.com/fuxio11" ;;
    zh:sum_i)     echo "安装完成。
您可以移除 USB 驱动器。

如果这个包对你有帮助：
ko-fi.com/fuxio11" ;;
    es:sum_u)     echo "Desinstalacion terminada!
Puede retirar la USB.

Si te sirvio:
ko-fi.com/fuxio11" ;;
    zh:sum_u)     echo "卸载完成。
您可以移除 USB 驱动器。

如果这个包对你有帮助：
ko-fi.com/fuxio11" ;;
    es:reboot30)  echo "
Reinicio automatico en 30 s.
Pulse Reiniciar para reiniciar ahora." ;;
    zh:reboot30)  echo "30秒后自动重启。按“重新启动”立即重新启动。" ;;
    es:ttskip)    echo "
ATENCION: TouchTune omitido - Common.js modificado por otra herramienta." ;;
    zh:ttskip)    echo "警告：TouchTune 已跳过 - Common.js 已被其他工具更改。" ;;
    es:ttfix)     echo "Common.js parcheado: restaurando antes de TouchTune" ;;
    zh:ttfix)     echo "Common.js 已修补：在 TouchTune 之前恢复" ;;
    es:conf_i)    echo "Continuar la instalacion?
Modulos: ${_mods_text}" ;;
    zh:conf_i)    echo "继续安装吗？模块： ${_mods_text}" ;;
    es:conf_u)    echo "Continuar la desinstalacion?
Modulos: ${_mods_text}" ;;
    zh:conf_u)    echo "继续卸载吗？模块： ${_mods_text}" ;;
    es:quitm)     echo "Salir sin modificar nada?" ;;
    zh:quitm)     echo "不做任何改变就退出？" ;;
  esac
}
LBL_INSTALL() { case "${LANG_CODE}" in fr) echo "Installer";; de) echo "Installieren";; es) echo "Instalar";; zh) echo "安装";; *) echo "Install";; esac; }
LBL_UNINSTALL() { case "${LANG_CODE}" in fr) echo "Desinstaller";; de) echo "Deinstallieren";; es) echo "Desinstalar";; zh) echo "卸载";; *) echo "Uninstall";; esac; }
LBL_LANG() { case "${LANG_CODE}" in fr) echo "Langue";; de) echo "Sprache";; es) echo "Idioma";; zh) echo "语言";; *) echo "Language";; esac; }
LBL_CANCEL() { case "${LANG_CODE}" in fr) echo "Annuler";; de) echo "Abbrechen";; es) echo "Cancelar";; zh) echo "取消";; *) echo "Cancel";; esac; }
LBL_REBOOT() { case "${LANG_CODE}" in fr) echo "Redemarrer";; de) echo "Neustart";; es) echo "Reiniciar";; zh) echo "重新启动";; *) echo "Restart";; esac; }
LBL_YES() { case "${LANG_CODE}" in fr) echo "Oui";; de) echo "Ja";; es) echo "Si";; zh) echo "是的";; *) echo "Yes";; esac; }
LBL_NO() { case "${LANG_CODE}" in fr) echo "Non";; de) echo "Nein";; es) echo "No";; zh) echo "不";; *) echo "No";; esac; }
LBL_QUIT() { case "${LANG_CODE}" in fr) echo "Quitter";; de) echo "Beenden";; es) echo "Salir";; zh) echo "关闭";; *) echo "Quit";; esac; }
LBL_BACK() { case "${LANG_CODE}" in fr) echo "Retour";; de) echo "Zurueck";; es) echo "Volver";; zh) echo "返回";; *) echo "Back";; esac; }

# Progress popup: replaces whatever dialog is on screen (non-blocking,
# the install keeps running behind it)
progress() {
  # $1 = T() text containing %s, $2 = module name. Substitute %s via sed so
  # the literal \n stays untouched (jci-dialog renders \n itself).
  _ptxt=$(echo "$1" | sed "s/%s/$2/g")
  killall -q jci-dialog
  /jci/tools/jci-dialog --info --title="All-in-one mods" \
    --text="${_ptxt}" --no-cancel &
}

# Reboot summary: shows what was done; user can press Restart to reboot
# immediately, otherwise the CMU reboots automatically after 30 seconds.
final_reboot() {
  killall -q jci-dialog
  /jci/tools/jci-dialog --info --title="All-in-one mods" \
    --text="$(T $1)${SUMMARY_NOTE}$(T reboot30)" \
    --ok-label="$(LBL_REBOOT)" &
  _dlg=$!
  for _i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 \
            21 22 23 24 25 26 27 28 29 30
  do
    kill -0 ${_dlg} 2>/dev/null || break   # user pressed Restart -> reboot now
    sleep 1
  done
  killall -q jci-dialog
  reboot
}

# TouchTune wrapper: runs its installer with the built-in reboot neutralized
# (we control the reboot ourselves, and TouchTune must run BEFORE the AIO
# modules that patch Common.js)
run_touchtune() {
  # Neutralize TouchTune's own reboot (we control it ourselves).
  sed 's/^if ! mzd_reboot; then/if false; then/' \
    "${MYDIR}/touchtune/install-patches.sh" > "${MYDIR}/touchtune/install-patches-nr.sh"

  # Translate TouchTune's user-visible popups into the installer language.
  # This only patches our -nr copy; the signed payload keeps its checksum.
  _nr="${MYDIR}/touchtune/install-patches-nr.sh"
  case "${LANG_CODE}" in
    fr)
      sed -i \
        -e 's/verb=Installing/verb=Installation de/' \
        -e 's/verb=Removing/verb=Desinstallation de/' \
        -e 's/Do not remove the USB or press any buttons\./Ne retirez pas la cle et ne touchez aucun bouton./' \
        -e 's/TouchTune was installed and verified\./TouchTune installe et verifie./' \
        -e 's/TouchTune was removed and verified\./TouchTune retire et verifie./' \
        -e 's/Remove the USB\. Restarting\.\.\./Ne retirez PAS la cle - installation en cours\.\.\./' \
        -e 's/TouchTune could not complete the requested change\./TouchTune na pas pu terminer la modification./' \
        -e 's/TouchTune could not verify the final CMU state\./TouchTune na pas pu verifier letat final./' \
        -e 's/TouchTune will not restart the CMU\./Le CMU ne redemarrera pas./' \
        -e 's/Keep the USB and review touchtune\.log\./Gardez la cle et consultez touchtune.log./' \
        -e 's/TouchTune USB validation failed\./Validation USB TouchTune echouee./' \
        -e 's/Nothing was changed\./Rien na ete modifie./' \
        -e 's/TouchTune could not read your selection\./TouchTune na pas pu lire votre choix./' \
        -e 's/TouchTune could not load its verified helper\./TouchTune na pas pu charger son module verifie./' \
        "${_nr}" ;;
    de)
      sed -i \
        -e 's/verb=Installing/verb=Installation von/' \
        -e 's/verb=Removing/verb=Entfernen von/' \
        -e 's/Do not remove the USB or press any buttons\./USB-Stick nicht entfernen und keine Tasten druecken./' \
        -e 's/TouchTune was installed and verified\./TouchTune installiert und verifiziert./' \
        -e 's/TouchTune was removed and verified\./TouchTune entfernt und verifiziert./' \
        -e 's/Remove the USB\. Restarting\.\.\./USB-Stick NICHT entfernen - Installation laeuft weiter\.\.\./' \
        -e 's/TouchTune could not complete the requested change\./TouchTune konnte die Aenderung nicht abschliessen./' \
        -e 's/TouchTune could not verify the final CMU state\./TouchTune konnte den Endzustand nicht verifizieren./' \
        -e 's/TouchTune will not restart the CMU\./Der CMU wird nicht neu gestartet./' \
        -e 's/Keep the USB and review touchtune\.log\./USB-Stick behalten und touchtune.log pruefen./' \
        -e 's/TouchTune USB validation failed\./USB-Validierung fehlgeschlagen./' \
        -e 's/Nothing was changed\./Nichts wurde geaendert./' \
        -e 's/TouchTune could not read your selection\./Auswahl konnte nicht gelesen werden./' \
        -e 's/TouchTune could not load its verified helper\./Verifiziertes Hilfsskript konnte nicht geladen werden./' \
        "${_nr}" ;;
    es)
      sed -i \
        -e 's/verb=Installing/verb=Instalacion de/' \
        -e 's/verb=Removing/verb=Desinstalacion de/' \
        -e 's/Do not remove the USB or press any buttons\./No retire la USB ni pulse botones./' \
        -e 's/TouchTune was installed and verified\./TouchTune instalado y verificado./' \
        -e 's/TouchTune was removed and verified\./TouchTune eliminado y verificado./' \
        -e 's/Remove the USB\. Restarting\.\.\./NO retire la USB - la instalacion continua\.\.\./' \
        -e 's/TouchTune could not complete the requested change\./TouchTune no pudo completar el cambio./' \
        -e 's/TouchTune could not verify the final CMU state\./TouchTune no pudo verificar el estado final./' \
        -e 's/TouchTune will not restart the CMU\./El CMU no se reiniciara./' \
        -e 's/Keep the USB and review touchtune\.log\./Guarde la USB y revise touchtune.log./' \
        -e 's/TouchTune USB validation failed\./Fallo la validacion del USB./' \
        -e 's/Nothing was changed\./No se modifico nada./' \
        -e 's/TouchTune could not read your selection\./No se pudo leer su eleccion./' \
        -e 's/TouchTune could not load its verified helper\./No se pudo cargar el auxiliar verificado./' \
        "${_nr}" ;;
    *)  # en/zh fallback: keep English but fix the misleading restart text
      sed -i 's/Remove the USB\. Restarting\.\.\./Do NOT remove the USB - installation continues\.\.\./' \
        "${_nr}" ;;
  esac

  sh "${_nr}" "$1"
}

pick_language() {
  /jci/tools/jci-dialog --3-button-dialog     --title="Language / Langue"     --text="Select language / Choisir la langue"     --ok-label="English"     --cancel-label="Francais"     --button3-label="More..."
  case $? in
    0) LANG_CODE=en; return ;;
    1) LANG_CODE=fr; return ;;
  esac
  /jci/tools/jci-dialog --3-button-dialog     --title="Language / Idioma"     --text="Select / Elegir"     --ok-label="Deutsch"     --cancel-label="Espanol"     --button3-label="Chinese"
  case $? in
    0) LANG_CODE=de ;;
    1) LANG_CODE=es ;;
    2) LANG_CODE=zh ;;
    *) LANG_CODE=en ;;
  esac
}

# If no language was chosen on the PC tool, ask first
case "${LANG_CODE}" in en|fr|de|es|zh) ;; *) pick_language ;; esac

CHOICE=255
while true
do
  /jci/tools/jci-dialog --3-button-dialog \
    --title="All-in-one mods" \
    --text="$(T menu)" \
    --ok-label="$(LBL_INSTALL)" \
    --cancel-label="$(LBL_UNINSTALL)" \
    --button3-label="$(LBL_CANCEL)"
  _m=$?

  if [ $_m -eq 0 ] || [ $_m -eq 1 ]
  then
    # --- Confirmation: Oui / Non / Langue ---
    if [ $_m -eq 0 ]; then _ctxt=$(T conf_i); else _ctxt=$(T conf_u); fi
    /jci/tools/jci-dialog --3-button-dialog \
      --title="All-in-one mods" \
      --text="${_ctxt}" \
      --ok-label="$(LBL_YES)" \
      --cancel-label="$(LBL_NO)" \
      --button3-label="$(LBL_LANG)"
    _c=$?
    if [ $_c -eq 0 ]; then CHOICE=$_m; break; fi
    if [ $_c -eq 2 ]; then pick_language; fi
    # Non -> back to main menu
  else
    # --- Annuler: Quitter / Langue / Retour ---
    /jci/tools/jci-dialog --3-button-dialog \
      --title="All-in-one mods" \
      --text="$(T quitm)" \
      --ok-label="$(LBL_QUIT)" \
      --cancel-label="$(LBL_LANG)" \
      --button3-label="$(LBL_BACK)"
    _q=$?
    if [ $_q -eq 0 ]; then CHOICE=99; break; fi   # Quit
    if [ $_q -eq 1 ]; then pick_language; fi      # Langue -> back to menu
    # Retour -> back to menu
  fi
done

if [ $CHOICE -eq 0 ]
then
  # ============================================================
  # INSTALL
  # ============================================================
  exec > "${MYDIR}/logs/install.log" 2>&1
  echo "=== all-in-one install start ==="
  echo "Modules: ${_mods_text}"

  progress "$(T prog_i)" "$(T install)"

  # --- TouchTune FIRST: it refuses any Common.js that is not stock or its own,
  #     and the AIO modules below patch that file ---
  SUMMARY_NOTE=""
  if [ "${MOD_TOUCHTUNE}" = "1" ]
  then
    progress "$(T prog_i)" "TouchTune"
    _tt_cjs=/jci/gui/common/js/Common.js
    _tt_stock=376b30a46366a543122956d7feb1b44f147425015837a4d83fedf12a67943351
    _tt_patched=019eba18e8d629ddb1d55563aab138ce1eb3329fab67b71d9b4178377cf9d9ce
    _tt_sha=$(sha256sum "${_tt_cjs}" 2>/dev/null | awk '{print $1}')
    [ -z "${_tt_sha}" ] && _tt_sha=$(openssl dgst -sha256 "${_tt_cjs}" 2>/dev/null | awk '{print $NF}')
    case "${_tt_sha}" in
      "${_tt_stock}"|"${_tt_patched}")
        : # stock or already TouchTune — nothing to repair
        ;;
      *)
        # Common.js already patched (e.g. previous AIO install): silent
        # auto-update path — restore the backup so TouchTune can run.
        echo "Common.js sha=${_tt_sha} not recognized; restoring backup before TouchTune"
        . "${MYDIR}/aio/_common.sh"
        restore_file "${_tt_cjs}" && echo "Common.js restored from backup"
        _tt_sha=$(sha256sum "${_tt_cjs}" 2>/dev/null | awk '{print $1}')
        [ -z "${_tt_sha}" ] && _tt_sha=$(openssl dgst -sha256 "${_tt_cjs}" 2>/dev/null | awk '{print $NF}')
        ;;
    esac
    case "${_tt_sha}" in
      "${_tt_stock}"|"${_tt_patched}")
        run_touchtune touch-while-driving
        TT_STATUS=$?
        echo "=== TouchTune finished with status ${TT_STATUS} ==="
        # TouchTune relocks the rootfs read-only and re-arms the watchdog:
        # reopen both or the remaining modules fail and the CMU may reset
        mount -o rw,remount /
        echo 1 > /sys/class/gpio/Watchdog\ Disable/value 2>/dev/null
        ;;
      *)
        TT_STATUS=skipped
        SUMMARY_NOTE="$(T ttskip)"
        echo "TouchTune skipped: unrecognized Common.js sha=${_tt_sha}"
        ;;
    esac
  fi

  if [ "${MOD_OEM_AA}" = "1" ]
  then
    progress "$(T prog_i)" "oem-aa-mod"
    # --- Read use_protocol_v1_6 from the config being deployed ---
    CONF="${MYDIR}/resources/libpatch.conf"
    USE_PROTOCOL_V16="false"
    if [ -f "${CONF}" ]
    then
      val=$(sed 's/#.*//' "${CONF}" \
              | grep -i '^[[:space:]]*use_protocol_v1_6[[:space:]]*=' \
              | tail -n1 | cut -d'=' -f2- | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
      case "${val}" in
        true|1|yes|on) USE_PROTOCOL_V16="true" ;;
      esac
    fi
    echo "use_protocol_v1_6 = ${USE_PROTOCOL_V16} (from ${CONF})"

    # --- Backup and patch jciAAPA in sm.conf and sm_WCP.conf ---
    for conf in sm.conf sm_WCP.conf
    do
      if [ ! -e "/jci/sm/${conf}.orig" ]
      then
        cp -a "/jci/sm/${conf}" "/jci/sm/${conf}.orig"
        echo "Backed up ${conf}"
      else
        echo "${conf} backup already exists"
      fi

      if ! grep -q "libpatch-blmjciaapa" "/jci/sm/${conf}"
      then
        sed -i '/name="jciAAPA"/a\            <environ_var env_name="LD_PRELOAD" env_value="/data_persist/oem-aa-mod/libpatch-blmjciaapa.so"/>' "/jci/sm/${conf}"
        echo "Patched jciAAPA in ${conf}"
      else
        echo "jciAAPA already patched in ${conf}, skipping"
      fi

      if ! grep -q "libpatch-svcjcinavi" "/jci/sm/${conf}"
      then
        sed -i '/name="jcinavi"/a\            <environ_var env_name="LD_PRELOAD" env_value="/data_persist/oem-aa-mod/libpatch-svcjcinavi.so"/>' "/jci/sm/${conf}"
        echo "Patched jcinavi in ${conf}"
      else
        echo "jcinavi already patched in ${conf}, skipping"
      fi

      if [ "${USE_PROTOCOL_V16}" = "true" ]
      then
        if ! grep -q "libpatch-aap_service" "/jci/sm/${conf}"
        then
          sed -i '/name="aap_service"/a\            <environ_var env_name="LD_PRELOAD" env_value="/data_persist/oem-aa-mod/libpatch-aap_service.so"/>' "/jci/sm/${conf}"
          echo "Patched aap_service in ${conf}"
        else
          echo "aap_service already patched in ${conf}, skipping"
        fi
      else
        echo "use_protocol_v1_6 is false, skipping aap_service patch in ${conf}"
      fi
    done

    # --- Install libraries ---
    mkdir -p /data_persist/oem-aa-mod
    cp "${MYDIR}/libpatch-blmjciaapa.so" /data_persist/oem-aa-mod/
    echo "libpatch-blmjciaapa.so has been copied"
    cp "${MYDIR}/libpatch-svcjcinavi.so" /data_persist/oem-aa-mod/
    echo "libpatch-svcjcinavi.so has been copied"
    if [ "${USE_PROTOCOL_V16}" = "true" ]
    then
      cp "${MYDIR}/libpatch-aap_service.so" /data_persist/oem-aa-mod/
      echo "libpatch-aap_service.so has been copied"
    else
      echo "use_protocol_v1_6 is false, skipping libpatch-aap_service.so copy"
    fi
    cp "${MYDIR}/resources/libpatch.conf" /data_persist/oem-aa-mod/
    echo "libpatch.conf has been copied"
    chmod 0644 /data_persist/oem-aa-mod/libpatch-*.so

    # --- Backup and install XML configs ---
    for xml in aap_system_attributes.xml aap_system_attributes_UCP.xml
    do
      if [ ! -e "/etc/${xml}.orig" ]
      then
        cp -a "/etc/${xml}" "/etc/${xml}.orig"
        echo "Backed up ${xml}"
      else
        echo "${xml}.orig already exists, skipping backup"
      fi
      cp "${MYDIR}/resources/${xml}" "/etc/${xml}"
      echo "Installed ${xml}"
    done

    sync
    echo "=== oem-aa-mod part complete ==="
  fi

  # --- AIO-derived modules (sorted order; file-copy tweaks run before seds) ---
  for _m in "${MYDIR}"/aio/*/; do
    if aio_mod_enabled "${_m}" && [ -f "${_m}install.sh" ]
    then
      echo "=== AIO module $(basename "${_m}") install ==="
      progress "$(T prog_i)" "$(basename "${_m}")"
      MYDIR="${_m}" sh "${_m}install.sh"
    fi
  done
  sync

  # Summary + reboot (immediate on button press, or auto after 30 s)
  final_reboot sum_i

elif [ $CHOICE -eq 1 ]
then
  # ============================================================
  # UNINSTALL
  # ============================================================
  exec > "${MYDIR}/logs/uninstall.log" 2>&1
  echo "=== all-in-one uninstall start ==="

  progress "$(T prog_u)" "$(T uninstall)"

  if [ "${MOD_OEM_AA}" = "1" ]
  then
    progress "$(T prog_u)" "oem-aa-mod"
    for conf in sm.conf sm_WCP.conf
    do
      if [ -e "/jci/sm/${conf}.orig" ]
      then
        cp -a "/jci/sm/${conf}.orig" "/jci/sm/${conf}"
        rm "/jci/sm/${conf}.orig"
        echo "Restored ${conf} from backup"
      else
        echo "WARNING: ${conf}.orig not found; removing LD_PRELOAD lines manually"
        sed -i '/env_value="\/data_persist\/oem-aa-mod\//d' "/jci/sm/${conf}"
        echo "Removed LD_PRELOAD entries from ${conf}"
      fi
    done

    for xml in aap_system_attributes.xml aap_system_attributes_UCP.xml
    do
      if [ -e "/etc/${xml}.orig" ]
      then
        cp -a "/etc/${xml}.orig" "/etc/${xml}"
        rm "/etc/${xml}.orig"
        echo "Restored ${xml} from backup"
      else
        echo "WARNING: ${xml}.orig not found, skipping restore"
      fi
    done

    rm -f /data_persist/oem-aa-mod/libpatch-blmjciaapa.so
    echo "Removed libpatch-blmjciaapa.so"
    rm -f /data_persist/oem-aa-mod/libpatch-svcjcinavi.so
    echo "Removed libpatch-svcjcinavi.so"
    rm -f /data_persist/oem-aa-mod/libpatch-aap_service.so
    echo "Removed libpatch-aap_service.so"
    rm -f /data_persist/oem-aa-mod/libpatch.conf
    echo "Removed libpatch.conf"
    rmdir /data_persist/oem-aa-mod 2>/dev/null && echo "Removed /data_persist/oem-aa-mod directory"

    sync
    echo "=== oem-aa-mod removed ==="
  fi

  # --- AIO-derived modules uninstall (reverse order) ---
  for _m in $(ls -rd "${MYDIR}"/aio/*/ 2>/dev/null); do
    if aio_mod_enabled "${_m}" && [ -f "${_m}uninstall.sh" ]
    then
      echo "=== AIO module $(basename "${_m}") uninstall ==="
      progress "$(T prog_u)" "$(basename "${_m}")"
      MYDIR="${_m}" sh "${_m}uninstall.sh"
    fi
  done
  sync

  # TouchTune LAST on uninstall: the AIO restores above must have put
  # Common.js back to stock first, or TouchTune will refuse the file
  if [ "${MOD_TOUCHTUNE}" = "1" ]
  then
    progress "$(T prog_u)" "TouchTune"
    run_touchtune --restore
    TT_STATUS=$?
    echo "=== TouchTune restore finished with status ${TT_STATUS} ==="
    mount -o rw,remount /
    echo 1 > /sys/class/gpio/Watchdog\ Disable/value 2>/dev/null
  fi

  # Summary + reboot (immediate on button press, or auto after 30 s)
  final_reboot sum_u

else
  # ============================================================
  # CANCEL
  # ============================================================
  sync
  /jci/tools/jci-dialog --info --title="All-in-one mods" \
    --text="$(T cancelled)" \
    --ok-label="OK" --no-cancel
  exit 0
fi

exit 0
