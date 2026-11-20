# Wi-Fi research — native wireless Android Auto without a dongle

## Goal
Use the CMU's built-in Wi-Fi chip as the transport for wireless
Android Auto, replacing an external AA-wireless dongle.

## What we know (74.00.324)
- Linux-based CMU (JCI/Visteon, Gen 6 Mazda Connect)
- wlan0 exists; in stock it runs as an ACCESS POINT (hostapd)
- Firmware ships wpa_supplicant, hostapd, sshd (OpenSSH 5.9), iptables
- aap_service is the daemon that speaks the AA protocol (oem-aa-mod
  already shims it via LD_PRELOAD for GAL 1.6 / HUD)
- oem-aa-mod libpatch.conf already has bt_pairing_* options
- /data_persist/ survives reboots (our BACKUP_ROOT)

## OpenCMU prior art (read before writing anything)
- tweaks/74-earlier-wifi-init : bounded wait for wlan0 before start_wifi.sh
- tweaks/75-enable-ssh      : key-only SSH for on-device debugging
- tweaks/76-enable-wifi-client : client mode w/ wpa_supplicant + DHCP
- tweaks/60-startup-hook    : boot.d runtime all of the above need

## Theoretical path
1. wlan0 AP (hostapd) + DHCP (dnsmasq/udhcpd) — the AP SSID the phone joins
2. Route/BT pairing bootstrap so the phone discovers the AA service
3. aap_service accepting an IP transport session instead of USB
4. oem-aa-mod shims may need to advertise wireless capability

## Open questions
- Does aap_service already listen on a TCP port, or USB-only?
- Which process owns hostapd config in stock? (/jci/scripts/start_wifi.sh)
- Does wireless AA need a specific probe-response / BT handshake first?
- Power draw / coexistence with CarPlay service

## Safety
Everything on this branch is EXPERIMENTAL. Nothing ships to main until
tested on the bench unit. Reversibility rules apply (backup + surgical revert).
