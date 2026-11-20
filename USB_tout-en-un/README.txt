ALL-IN-ONE KEY — oem-aa-mod 0.10.0 + TouchTune 1.2.1
====================================================

A single installation applies:
1. oem-aa-mod: fixed DPI (round corners), touchscreen in Android Auto,
   HUD navigation (GAL 1.6), low-latency audio, mute=pause...
2. TouchTune: touchscreen enabled while driving in the Mazda UI.
Plus the selected AIO tweaks (menu loop, no beeps, no disclaimer,
bigger album art, dead-service removal...).

REQUIREMENTS
- CMU firmware: 74.00.324 (Settings → System → About)
- USB stick ≤32 GB, FAT32, MBR partition

INSTALLATION
- Copy EVERYTHING in this folder to the ROOT of the stick
- Ignition ON → home screen → insert the stick → wait ~60 s
- "All-in-one mods" dialog → Install
- Everything runs automatically; the CMU reboots on its own.
  Do not touch anything during the process.

UNINSTALL
- Same stick → "Uninstall" → restores the backups of every mod.

OPTIONS (resources/libpatch.conf, editable on PC)
- touch = true                touchscreen in AA
- hud = true / svcnavi        HUD guidance
- use_protocol_v1_6 = true    full nav protocol (maneuvers/lanes)
- aa_audio_low_latency = true audio latency fix
- mute_pauses_phone = true    mute = media pause
- block_headunit_media_play = true
- force_street_name = false   → true if street name missing on HUD (EU)
- bt_pairing_show_device_notification = false → true to identify
  an unrecognized AA dongle
- bt_pairing_bypass_all_devices = false → true if dongle unknown

LOGS
- logs/install.log (oem-aa) and touchtune/touchtune.log on the stick.

ADDING MORE MODS LATER
- Edit resources/libpatch.conf for oem-aa-mod options
- Add modules as a subfolder under aio/ — they run in sorted order.

SOURCES
- https://github.com/VitaliyKurokhtin/oem-aa-mod (0.10.0)
- https://github.com/Bijan-A/oem-aa-mod-installer
- https://github.com/Miatafy/TouchTune (1.2.1)
