oem-aa-mod 0.10.0 — Installation on Mazda CMU
=============================================

REQUIREMENTS
- CMU firmware: 74.00.324 (check on screen:
  Settings → System → About → Version information)
- USB stick 32 GB max, FAT32 formatted

USB STICK PREPARATION
- Copy EVERYTHING in this folder to the ROOT of the USB stick
  (run.sh, jci-autoupdate, the .up file, the .so files, resources/)
- Eject the stick cleanly

INSTALLATION IN THE CAR
- Ignition/accessories on, plug the stick into the console USB port
- Wait a few seconds: an "oem-aa-mod" dialog appears
- Choose "Install" — DO NOT remove the stick during installation
- The CMU reboots itself after ~5 s; the stick can then be removed

ENABLED OPTIONS IN resources/libpatch.conf
- touch = true              (touchscreen in Android Auto)
- hud = true                (guidance on the HUD, hud_transport = svcnavi)
- use_protocol_v1_6 = true  (full nav protocol: maneuvers/lanes/ETA)
- aa_audio_low_latency = true   (AUDIO LATENCY FIX — enabled)
- mute_pauses_phone = true  (mute = pause media on the phone)
- block_headunit_media_play = true (AA does not auto-resume playback)
- force_street_name = false (default — set to true if the street
                            name does not appear on the HUD in EU)

UNINSTALL
- Reinsert the same stick, choose "Uninstall" — everything is restored
  from the backups (.orig created at first install).

LOGS
- A logs/ folder is created on the stick (install.log / uninstall.log).

SOURCE
- https://github.com/VitaliyKurokhtin/oem-aa-mod (mod, v0.10.0)
- https://github.com/Bijan-A/oem-aa-mod-installer (installer)
- SHA256 verified 2026-11-18: e512b533...6f4e
