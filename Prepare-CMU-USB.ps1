# ==============================================================
#  CMU Mods - USB prep tool (Mazda Connect v74.00.324)
#  WPF UI - Languages: EN / FR / DE
# ==============================================================
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName WindowsFormsIntegration
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$SrcDir = Join-Path $PSScriptRoot "USB_tout-en-un"
$CapDir = Join-Path $PSScriptRoot "USB_capture-ecran"

# Mode picker: install key vs screen-capture key (bilingual, shown before UI)
$modeRes = [System.Windows.Forms.MessageBox]::Show(
    "Which USB key do you want to prepare? / Quelle cle USB preparer ?`n`n" +
    "YES / OUI  = Install key (mods) / cle d'installation (mods)`n" +
    "NO / NON   = Screen capture key / cle de capture d'ecran",
    "USB key type / Type de cle",
    "YesNoCancel", "Question")
if ($modeRes -eq 'Cancel') { exit 0 }
$script:capMode = ($modeRes -eq 'No')
if ($script:capMode) { $SrcDir = $CapDir }

$srcOk = if ($script:capMode) { Test-Path (Join-Path $SrcDir "capture.sh") } else { Test-Path (Join-Path $SrcDir "run.sh") }
if (-not $srcOk) {
    [System.Windows.Forms.MessageBox]::Show("Dossier source introuvable : $SrcDir", "Erreur", "OK", "Error") | Out-Null
    exit 1
}
$ImgDir = Join-Path $PSScriptRoot "images"
# Your support link, shown at the bottom of the window and in the CMU
# end-of-install message. Replace with your real page (GitHub Sponsors,
# Ko-fi, PayPal...). Same placeholder is in USB_tout-en-un/run.sh.
$TipUrl = "https://ko-fi.com/fuxio11"

# ---------- Translations ----------
$script:lang = 'en'
$tr = @{
    title       = @{ fr='Cle USB mods CMU';                              en='CMU Mods USB';                                   de='CMU-Mods USB' ; es='USB mods CMU'; zh='CMU 模组 USB' }
    subtitle    = @{ fr='Preparation de cle USB - Mazda Connect v74.00.324'; en='USB drive preparation - Mazda Connect v74.00.324'; de='USB-Vorbereitung - Mazda Connect v74.00.324' ; es='Preparacion de USB - Mazda Connect v74.00.324'; zh='USB 驱动器准备 - Mazda Connect v74.00.324' }
    drive       = @{ fr='Cle USB';                                       en='USB drive';                                      de='USB-Stick' ; es='Unidad USB'; zh='USB驱动器' }
    refresh     = @{ fr='Rafraichir';                                    en='Refresh';                                        de='Aktualisieren' ; es='Actualizar'; zh='刷新' }
    grpMods     = @{ fr='Modules';                                       en='Modules';                                        de='Module' ; es='Modulos'; zh='模块' }
    chkAA       = @{ fr='oem-aa-mod 0.10.0';                             en='oem-aa-mod 0.10.0';                              de='oem-aa-mod 0.10.0' ; es='oem-aa-mod 0.10.0'; zh='OEM-aa-mod 0.10.0' }
    chkAAsub    = @{ fr='DPI, tactile AA, HUD, audio';                   en='DPI, AA touch, HUD, audio';                      de='DPI, AA-Touch, HUD, Audio' ; es='DPI, tactil AA, HUD, audio'; zh='DPI、AA 触摸、HUD、音频' }
    chkTT       = @{ fr='TouchTune 1.2.1';                               en='TouchTune 1.2.1';                                de='TouchTune 1.2.1' ; es='TouchTune 1.2.1'; zh='触摸调音1.2.1' }
    chkTTsub    = @{ fr='tactile en roulant';                            en='touch while driving';                            de='Touch waehrend Fahrt' ; es='tactil en marcha'; zh='开车时触摸' }
    grpAio      = @{ fr='Tweaks communaute (AIO)';                       en='Community tweaks (AIO)';                         de='Community-Tweaks (AIO)' ; es='Tweaks comunidad (AIO)'; zh='社区调整 (AIO)' }
    grpOpt      = @{ fr='Options oem-aa-mod';                            en='oem-aa-mod options';                             de='oem-aa-mod-Optionen' ; es='Opciones oem-aa-mod'; zh='OEM-aa-mod 选项' }
    aio1        = @{ fr='Menu principal en boucle';                      en='Main menu loop';                                 de='Hauptmenue-Schleife' ; es='Menu principal en bucle'; zh='主菜单循环' }
    aio2        = @{ fr='Listes en boucle';                              en='List loop';                                      de='Listen-Schleife' ; es='Listas en bucle'; zh='列表循环' }
    aio3        = @{ fr='Defilement plus rapide';                        en='Shorter scroll delay';                           de='Kuerzeres Scrollen' ; es='Desplazamiento mas rapido'; zh='更短的滚动延迟' }
    aio4        = @{ fr='Plus de bips';                                  en='No beeps';                                       de='Keine Pieptoene' ; es='Sin pitidos'; zh='无蜂鸣声' }
    aio5        = @{ fr="Plus d'ecran d'avertissement";                  en='No startup disclaimer';                          de='Kein Starthinweis' ; es='Sin aviso de arranque'; zh='无启动免责声明' }
    aio6        = @{ fr='Retirer texte camera de recul';                 en='Remove reverse-camera text';                     de='Kamera-Warntext weg' ; es='Quitar texto camara trasera'; zh='删除倒车摄像头文字' }
    aio7        = @{ fr='Menu diagnostic rapide';                        en='Quick diagnostic menu';                          de='Schnelles Diagnosemenue' ; es='Menu diagnostico rapido'; zh='快速诊断菜单' }
    aio8        = @{ fr="Pochettes d'album agrandies";                   en='Bigger album art';                               de='Groessere Cover' ; es='Caratula mas grande'; zh='更大的专辑封面' }
    aio9        = @{ fr="Retirer Aha/Stitcher/Pandora/SiriusXM";         en='Remove Aha/Stitcher/Pandora/SiriusXM';             de='Aha/Stitcher/Pandora/SiriusXM weg' ; es='Quitar Aha/Stitcher/Pandora/SiriusXM'; zh='移除Aha/Stitcher/Pandora/SiriusXM' }
    opt_touch   = @{ fr='Tactile dans Android Auto';                     en='Touch in Android Auto';                          de='Touch in Android Auto' ; es='Tactil en Android Auto'; zh='Android Auto 中的触摸' }
    opt_hud     = @{ fr='Guidance sur le HUD';                           en='HUD guidance';                                   de='HUD-Anleitung' ; es='Guiado en HUD'; zh='平视显示器引导' }
    opt_v16     = @{ fr='Protocole nav GAL 1.6';                         en='GAL 1.6 nav protocol';                           de='GAL-1.6-Naviprotokoll' ; es='Protocolo nav GAL 1.6'; zh='GAL 1.6 导航协议' }
    opt_lat     = @{ fr='Audio basse latence';                           en='Low-latency audio';                              de='Niedrige Audio-Latenz' ; es='Audio baja latencia'; zh='低延迟音频' }
    opt_mute    = @{ fr='Mute = pause media';                            en='Mute pauses media';                              de='Stumm = Pause' ; es='Mute = pausa media'; zh='静音暂停媒体' }
    opt_block   = @{ fr='Bloquer le play auto';                          en='Block auto-play';                                de='Auto-Play blockieren' ; es='Bloquear auto-play'; zh='阻止自动播放' }
    opt_unmute  = @{ fr='Unmute relance la lecture';                     en='Unmute resumes playback';                        de='Entstummen = Play' ; es='Unmute reanuda'; zh='取消静音恢复播放' }
    opt_street  = @{ fr='Nom de rue sur HUD (EU)';                       en='Street name on HUD (EU)';                        de='Strassenname HUD (EU)' ; es='Nombre calle en HUD (EU)'; zh='HUD 上的街道名称（欧盟）' }
    opt_btshow  = @{ fr='Afficher nom dongle AA (diag)';                 en='Show AA dongle name (diag)';                     de='AA-Dongle-Name (Diag)' ; es='Mostrar nombre dongle AA (diag)'; zh='显示 AA 加密狗名称（诊断）' }
    opt_btbyp   = @{ fr='Bypass pairage dongle inconnu';                 en='Bypass pairing unknown dongle';                  de='Pairing-Bypass unbekannt' ; es='Bypass emparejamiento desconocido'; zh='绕过配对未知加密狗' }
    write       = @{ fr='ECRIRE SUR LA CLE';                             en='WRITE TO USB DRIVE';                             de='AUF STICK SCHREIBEN' ; es='ESCRIBIR EN USB'; zh='写入 USB 驱动器' }
    preview     = @{ fr='Apercu';                                        en='Preview';                                        de='Vorschau' ; es='Vista previa'; zh='预览' }
    hoverhint   = @{ fr='Survolez une option pour voir la description';  en='Hover an option to see its description';         de='Option beruehren fuer Beschreibung' ; es='Pasa el raton sobre una opcion para ver su descripcion'; zh='将鼠标悬停在选项上即可查看其说明' }
    okdrive     = @{ fr='OK : MBR + FAT32 — compatible CMU.';            en='OK: MBR + FAT32 — CMU compatible.';              de='OK: MBR + FAT32 — CMU-kompatibel.' ; es='OK: MBR + FAT32 — compatible CMU.'; zh='好的：MBR + FAT32 — CMU 兼容。' }
    badfs       = @{ fr='Systeme de fichiers';                           en='File system';                                    de='Dateisystem' ; es='Sistema de archivos'; zh='文件系统' }
    badstyle    = @{ fr='Table de partition';                            en='Partition table';                                de='Partitionstabelle' ; es='Tabla de particiones'; zh='分区表' }
    badsize     = @{ fr='Taille';                                        en='Size';                                           de='Groesse' ; es='Tamano'; zh='尺寸' }
    needfat32   = @{ fr='FAT32 requis';                                  en='FAT32 required';                                 de='FAT32 erforderlich' ; es='FAT32 requerido'; zh='需要FAT32' }
    needmbr     = @{ fr='MBR requis';                                    en='MBR required';                                   de='MBR erforderlich' ; es='MBR requerido'; zh='需要主引导记录' }
    maxsize     = @{ fr='32 Go max recommande';                          en='32 GB max recommended';                          de='max. 32 GB empfohlen' ; es='max 32 GB recomendado'; zh='建议最大 32 GB' }
    nocmp       = @{ fr='NON COMPATIBLE';                                en='NOT COMPATIBLE';                                 de='NICHT KOMPATIBEL' ; es='NO COMPATIBLE'; zh='不兼容' }
    fixhint     = @{ fr='Reformater via diskpart (admin) : clean / convert mbr / create partition primary / format fs=fat32 quick'; en='Reformat via diskpart (admin): clean / convert mbr / create partition primary / format fs=fat32 quick'; de='Neu formatieren via diskpart (Admin): clean / convert mbr / create partition primary / format fs=fat32 quick' ; es='Reformatear con diskpart (admin): clean / convert mbr / create partition primary / format fs=fat32 quick'; zh='通过diskpart（管理员）重新格式化：清理/转换mbr/创建主分区/快速格式化fs=fat32' }
    nodrive     = @{ fr='Aucune cle USB detectee.';                      en='No USB drive detected.';                         de='Kein USB-Stick erkannt.' ; es='No se detecto unidad USB.'; zh='未检测到 USB 驱动器。' }
    copying     = @{ fr='Copie en cours...';                             en='Copying...';                                     de='Kopiere...' ; es='Copiando...'; zh='复制...' }
    done        = @{ fr="Termine ! Ejecte la cle, puis dans la voiture :`ncontact ON -> ecran d'accueil -> inserer la cle -> Install."; en="Done! Safely eject, then in the car:`nignition ON -> home screen -> insert drive -> Install."; de="Fertig! Stick sicher auswerfen, dann im Auto:`nZuendung AN -> Startbildschirm -> Stick einstecken -> Install." ; es='Terminado! Expulsa la USB, luego en el coche:`ncontacto ON -> pantalla inicio -> insertar USB -> Install.'; zh='！，：`n ON ->  -> U -> Install' }
    err         = @{ fr='ERREUR';                                        en='ERROR';                                          de='FEHLER' ; es='ERROR'; zh='错误' }
    pickone     = @{ fr='Coche au moins un module.';                     en='Check at least one module.';                     de='Mindestens ein Modul waehlen.' ; es='Marca al menos un modulo.'; zh='至少检查一个模块。' }
    nothing     = @{ fr='Rien a ecrire';                                 en='Nothing to write';                               de='Nichts zu schreiben' ; es='Nada que escribir'; zh='没什么可写的' }
    dupup       = @{ fr='Plusieurs fichiers .up a la racine — le CMU risque de lancer le mauvais'; en='Multiple .up files at root — CMU may run the wrong one'; de='Mehrere .up-Dateien — CMU koennte die falsche starten' ; es='Varios .up en la raiz — el CMU puede lanzar el incorrecto'; zh='根目录下有多个 .up 文件 — CMU 可能会运行错误的文件' }
    stray       = @{ fr='Fichiers residuels a la racine';                en='Leftover files at root';                         de='Restdateien im Wurzelverzeichnis' ; es='Archivos residuales en la raiz'; zh='根目录下的剩余文件' }
    askclean    = @{ fr="Des fichiers .up residuels ont ete trouves a la racine :`n{0}`n`nLes supprimer avant l'ecriture ? (Oui = supprimer, Non = annuler)"; en="Leftover .up file(s) found at root:`n{0}`n`nDelete them before writing? (Yes = delete, No = cancel)"; de="Restliche .up-Dateien gefunden:`n{0}`n`nVor dem Schreiben loeschen? (Ja = loeschen, Nein = abbrechen)" ; es='Se encontraron .up residuales en la raiz:`n{0}`n`nBorrarlos antes de escribir? (Si = borrar, No = cancelar)'; zh=' .up:`n{0}`n`n? (=, =)' }
    conflict    = @{ fr='CONFLIT';                                       en='CONFLICT';                                       de='KONFLIKT' ; es='CONFLICTO'; zh='冲突' }
    cleaned     = @{ fr='Fichiers residuels supprimes.';                 en='Leftover files removed.';                        de='Restdateien entfernt.' ; es='Archivos residuales eliminados.'; zh='剩余文件已删除。' }
    warnfw      = @{ fr='⚠ Uniquement pour firmware CMU 74.00.324 — verifiez dans Reglages > Systeme > A propos'; en='⚠ Only for CMU firmware 74.00.324 — check Settings > System > About'; de='⚠ Nur fuer CMU-Firmware 74.00.324 — pruefen unter Einstellungen > System > Info' ; es='⚠ Solo para firmware CMU 74.00.324 — verifica en Ajustes > Sistema > Acerca de'; zh='⚠ 仅适用于 CMU 固件 74.00.324 — 检查设置 > 系统 > 关于' }
    askfw       = @{ fr="Ce package ne fonctionne QUE sur le firmware 74.00.324.`nVotre CMU est bien en version 74.00.324 ?"; en="This package ONLY works on firmware 74.00.324.`nIs your CMU on version 74.00.324?"; de="Dieses Paket funktioniert NUR mit Firmware 74.00.324.`nIst Ihr CMU auf Version 74.00.324?" ; es='Este paquete SOLO funciona en firmware 74.00.324.`nTu CMU esta en version 74.00.324?'; zh=' 74.00.324。`n CMU  74.00.324 ?' }
    tiplink     = @{ fr='☕ Ce pack vous est utile ? Soutenez le projet'; en='☕ Found this useful? Support the project'; de='☕ Nuetzlich? Projekt unterstuetzen' ; es='☕ Te sirvio? Apoya el proyecto'; zh='☕ 支持本项目' }
    # --- Descriptions (preview panel) ---
    tip_chkAA   = @{ fr="Le mod principal pour Android Auto : corrige l'affichage deforme (ronds ovales), rend l'ecran tactile utilisable dans Android Auto, envoie la navigation sur le HUD, et corrige les coupures/latence audio."; en="The main Android Auto mod: fixes the stretched display (oval circles), makes the touchscreen work inside Android Auto, sends navigation to the head-up display, and fixes audio cuts/latency."; de="Der wichtigste Android-Auto-Mod: korrigiert die verzerrte Anzeige, macht den Touchscreen in Android Auto nutzbar, sendet Navigation aufs HUD und behebt Audioaussetzer." ; es='El mod principal de Android Auto: corrige la imagen deformada (circulos ovales), activa el tactil en Android Auto, envia la navegacion al HUD y corrige cortes/latencia de audio.'; zh='Android Auto ：（）、、HUD、/。' }
    tip_chkTT   = @{ fr="Reactive le tactile de l'ecran Mazda pendant que la voiture roule. Par defaut Mazda desactive le toucher en mouvement : avec ce mod, vous pouvez toucher les menus Mazda en roulant."; en="Re-enables the Mazda screen's touch while the car is moving. Mazda disables touch input when driving; this mod lets you tap the Mazda menus on the move."; de="Reaktiviert die Touchbedienung waehrend der Fahrt. Mazda sperrt Touch im Fahrbetrieb; dieser Mod erlaubt Tippen auf Mazda-Menues unterwegs." ; es='Reactiva el tactil de la pantalla Mazda con el coche en marcha. Mazda lo desactiva al conducir; con este mod puedes tocar los menus en movimiento.'; zh=' Mazda 。Mazda ；。' }
    tip_aio1    = @{ fr="Quand vous arrivez en bas du menu principal et continuez a tourner le bouton, ca revient en haut (au lieu de rester bloque en bas)."; en="When you scroll past the last item of the main menu, it loops back to the top instead of stopping."; de="Beim Scrollen ueber den letzten Menuepunkt hinaus springt es wieder nach oben." ; es='Al pasar del ultimo elemento del menu principal, vuelve al primero en vez de quedarse abajo.'; zh='。' }
    tip_aio2    = @{ fr="Meme chose mais pour les listes (musique, contacts...) : la fin de la liste boucle vers le debut."; en="Same idea for long lists (music, contacts...): scrolling past the end wraps around to the start."; de="Gleiches fuer lange Listen (Musik, Kontakte...): Am Ende wird zum Anfang gesprungen." ; es='Igual para listas largas (musica, contactos...): el final vuelve al inicio.'; zh='（、…）。' }
    tip_aio3    = @{ fr="Quand vous maintenez le bouton tourne pour defiler dans une liste, ca accelere plus vite. Les longues listes se parcourent plus rapidement."; en="When holding the commander knob to scroll a list, it speeds up sooner. Long lists are faster to browse."; de="Beim Scrollen mit dem Knopf beschleunigt die Liste frueher. Lange Listen sind schneller zu durchblättern." ; es='Al mantener el mando para desplazarse por una lista, acelera antes. Las listas largas se recorren mas rapido.'; zh='，。' }
    tip_aio4    = @{ fr="Supprime les 'bip' de confirmation quand vous touchez l'ecran ou tournez le bouton."; en="Removes the 'beep' sounds when you tap the screen or turn the knob."; de="Entfernt die Pieptoene beim Beruehren des Bildschirms oder Drehen des Knopfs." ; es='Quita los pitidos de confirmacion al tocar la pantalla o girar el mando.'; zh='。' }
    tip_aio5    = @{ fr="Supprime l'ecran 'Ne pas utiliser en conduisant' que vous devez valider a chaque demarrage."; en="Removes the 'Do not use while driving' disclaimer screen you must dismiss at every startup."; de="Entfernt den Hinweisbildschirm 'Nicht waehrend der Fahrt bedienen' bei jedem Start." ; es='Quita la pantalla de advertencia que hay que aceptar en cada arranque.'; zh='。' }
    tip_aio6    = @{ fr="Enleve le texte d'avertissement affiche en bas de l'image de la camera de recul. L'image reste, seul le texte disparait."; en="Removes the warning text shown over the reversing camera image. The image stays, only the text goes away."; de="Entfernt den Warntext ueber dem Rueckfahrkamerabild. Das Bild bleibt, nur der Text verschwindet." ; es='Quita el texto de aviso mostrado sobre la imagen de la camara trasera. La imagen queda, solo el texto desaparece.'; zh='，。' }
    tip_aio7    = @{ fr="Le menu diagnostic cache (bouton retour + favori long) s'ouvre apres 1 seconde au lieu de 3-5."; en="The hidden diagnostic menu (back + long favorite press) opens after 1 second instead of 3-5."; de="Das versteckte Diagnosemenue oeffnet nach 1 Sekunde statt 3-5." ; es='El menu diagnostico oculto se abre en 1 segundo en vez de 3-5.'; zh='13-5。' }
    tip_aio8    = @{ fr="Affiche la pochette d'album en plus grand sur l'ecran 'En cours de lecture'."; en="Shows a bigger album cover on the 'Now Playing' screen."; de="Zeigt das Albumcover groesser im 'Aktuelle Wiedergabe'-Bildschirm an." ; es='Muestra la caratula del album mas grande en la pantalla Reproduciendo.'; zh='“”。' }
    tip_aio9    = @{ fr="Desactive les services morts ou inutilises : Aha, Stitcher (ferme en 2023), Pandora, les serveurs de radio internet et SiriusXM (USA uniquement). Ca libere de la memoire et accelere le demarrage. Vos applis telephone (Spotify, etc.) continuent de marcher."; en="Disables dead or unused services: Aha, Stitcher (shut down in 2023), Pandora, the internet-radio servers and SiriusXM (US-only). Frees memory and speeds up boot. Your phone apps (Spotify, etc.) keep working."; de="Deaktiviert tote bzw. ungenutzte Dienste: Aha, Stitcher (2023 eingestellt), Pandora, Internetradio-Server und SiriusXM (nur USA). Gibt Speicher frei und beschleunigt den Start. Telefon-Apps (Spotify usw.) funktionieren weiter." ; es='Desactiva servicios muertos o sin uso: Aha, Stitcher (cerro en 2023), Pandora, los servidores de radio por internet y SiriusXM (solo USA). Libera memoria y acelera el arranque. Las apps del telefono (Spotify, etc.) siguen funcionando.'; zh='停用失效或未使用的服务：Aha、Stitcher（2023年关闭）、Pandora、网络电台服务器和SiriusXM（仅美国）。释放内存并加快启动。手机应用（Spotify等）不受影响。' }
    tip_touch   = @{ fr="Permet de toucher l'ecran directement dans Android Auto (taper sur Maps, defiler Spotify...). Sans ca, il faut tout faire au bouton rotatif."; en="Lets you tap the screen directly inside Android Auto (tap Maps, scroll Spotify...). Without it, everything goes through the rotary knob."; de="Erlaubt direktes Antippen des Bildschirms in Android Auto. Ohne dies geht alles nur ueber den Drehknopf." ; es='Permite tocar la pantalla directamente dentro de Android Auto (Maps, Spotify...). Sin esto todo va por el mando.'; zh=' Android Auto （、Spotify…），。' }
    tip_hud     = @{ fr="Affiche les indications de navigation Android Auto (fleches, distances) sur l'affichage tete haute, comme le fait la navigation Mazda d'origine."; en="Shows Android Auto navigation instructions (arrows, distances) on the head-up display, like the built-in Mazda navigation does."; de="Zeigt Android-Auto-Navigationshinweise (Pfeile, Distanzen) auf dem Head-up-Display an." ; es='Muestra las indicaciones de navegacion de Android Auto (flechas, distancias) en el HUD, como la navegacion Mazda original.'; zh='HUDAA（、），。' }
    tip_v16     = @{ fr="Version plus complete du protocole d'envoi de navigation au HUD : affiche les voies, les panneaux et l'heure d'arrivee en plus des simples fleches. Necessaire pour le HUD sur les firmwares recents."; en="Fuller version of the HUD navigation protocol: shows lane guidance, road signs and ETA on top of simple arrows. Needed for HUD on newer firmwares."; de="Vollstaendigeres HUD-Navigationsprotokoll: zeigt Spurfuehrung, Verkehrszeichen und ETA zusaetzlich zu Pfeilen." ; es='Version mas completa del protocolo de navegacion al HUD: muestra carriles, senales y ETA ademas de flechas. Necesario para el HUD en firmwares recientes.'; zh='HUD：、ETA，HUD。' }
    tip_lat     = @{ fr="Reduit le delai audio d'Android Auto et corrige les micro-coupures de son au demarrage de la lecture."; en="Reduces Android Auto audio delay and fixes short sound cuts when playback starts."; de="Verringert die Audioverzoegerung und behebt kurze Tonaussetzer beim Wiedergabestart." ; es='Reduce el retardo de audio de Android Auto y corrige micro-cortes al iniciar la reproduccion.'; zh='AA，。' }
    tip_mute    = @{ fr="Quand vous coupez le son (bouton mute/volume), la musique sur le telephone se met vraiment en pause au lieu de continuer en silence."; en="When you mute the car audio, the music on the phone actually pauses instead of silently playing on."; de="Beim Stummschalten pausiert die Musik wirklich, statt lautlos weiterzulaufen." ; es='Al silenciar el audio del coche, la musica del telefono realmente se pausa en vez de seguir en silencio.'; zh='。' }
    tip_block   = @{ fr="Empeche la musique du telephone de repartir toute seule des qu'Android Auto se connecte. Vous choisissez quand lancer la lecture."; en="Stops phone music from auto-resuming the moment Android Auto connects. You choose when playback starts."; de="Verhindert, dass Telefonmusik automatisch startet, sobald Android Auto verbunden ist." ; es='Evita que la musica del telefono arranque sola al conectarse Android Auto. Tu eliges cuando reproducir.'; zh='AA，。' }
    tip_unmute  = @{ fr="Inverse de l'option precedente : quand vous reactivez le son, la lecture reprend automatiquement. A activer seulement si le blocage auto-play est actif."; en="Opposite of the previous option: when you unmute, playback resumes automatically. Only useful if auto-play blocking is on."; de="Gegenteil: Beim Entstummen wird die Wiedergabe fortgesetzt. Nur sinnvoll mit Auto-Play-Blockierung." ; es='Lo contrario: al quitar el silencio la reproduccion continua. Solo util si el bloqueo auto-play esta activo.'; zh='：，。' }
    tip_street  = @{ fr="Force l'affichage du nom de la rue actuelle sur le HUD (versions europeennes). Sans ca, le HUD peut ne montrer que les fleches."; en="Forces the current street name onto the head-up display (European versions). Without it, the HUD may only show arrows."; de="Erzwingt die Anzeige des Strassennamens auf dem HUD (EU-Versionen). Ohne dies zeigt das HUD evtl. nur Pfeile." ; es='Fuerza el nombre de la calle actual en el HUD (versiones europeas). Sin esto el HUD puede mostrar solo flechas.'; zh='HUD()，。' }
    tip_btshow  = @{ fr="Outil de diagnostic : affiche le nom de l'adaptateur/dongle detecte par le mod. Utile seulement pour depanner une connexion AA sans fil, sinon laisser decoche."; en="Diagnostic tool: shows the name of the adapter/dongle detected by the mod. Only useful to troubleshoot a wireless AA connection, otherwise leave unchecked."; de="Diagnosewerkzeug: zeigt den Namen des erkannten Dongles. Nur zur Fehlersuche, sonst deaktiviert lassen." ; es='Herramienta de diagnostico: muestra el nombre del adaptador detectado. Solo para depurar AA inalambrico, si no dejar desmarcado.'; zh='：，AA。' }
    tip_btbyp   = @{ fr="Pour les adaptateurs AA sans fil non reconnus : force le mod a les accepter quand meme. Ne l'activer que si votre dongle n'est pas detecte."; en="For unrecognized wireless-AA adapters: forces the mod to accept them anyway. Only enable if your dongle is not detected."; de="Fuer nicht erkannte drahtlose AA-Adapter: erzwingt die Akzeptanz. Nur aktivieren, wenn Ihr Dongle nicht erkannt wird." ; es='Para adaptadores AA inalambricos no reconocidos: fuerza al mod a aceptarlos. Activar solo si tu dongle no es detectado.'; zh='AA，。' }
}
function T($key) {
    $v = $tr[$key][$script:lang]
    if (-not $v) { $v = $tr[$key]['en'] }
    return $v
}

# ---------- Helpers ----------
function Get-UsbDrives {
    Get-Volume | Where-Object { $_.DriveType -eq 'Removable' -and $_.DriveLetter } |
        ForEach-Object {
            $part = Get-Partition -DriveLetter $_.DriveLetter -ErrorAction SilentlyContinue
            $style = "?"
            if ($part) {
                $disk = Get-Disk -Number $part.DiskNumber -ErrorAction SilentlyContinue
                if ($disk) { $style = $disk.PartitionStyle }
            }
            [PSCustomObject]@{
                Letter = $_.DriveLetter
                Label  = if ($_.FileSystemLabel) { $_.FileSystemLabel } else { "(no name)" }
                FS     = $_.FileSystem
                SizeGB = [math]::Round($_.Size / 1GB, 1)
                Style  = $style
            }
        }
}
function Test-Drive($d) {
    $problems = @()
    if ($d.FS -ne 'FAT32') { $problems += "$(T 'badfs') : $($d.FS) ($(T 'needfat32'))" }
    if ($d.Style -ne 'MBR') { $problems += "$(T 'badstyle') : $($d.Style) ($(T 'needmbr'))" }
    if ($d.SizeGB -gt 32)  { $problems += "$(T 'badsize') : $($d.SizeGB) GB ($(T 'maxsize'))" }
    return $problems
}
function Get-RootUpFiles($letter) { Get-ChildItem "${letter}:\" -Filter "*.up" -File -ErrorAction SilentlyContinue }
function Get-OurUpName { (Get-ChildItem $SrcDir -Filter "*.up" -File | Select-Object -First 1).Name }
function Get-StrayRootItems($letter) {
    $expected = @{}
    Get-ChildItem $SrcDir -Force | ForEach-Object { $expected[$_.Name.ToLower()] = $true }
    $expected['mods.cfg'] = $true
    $expected['system volume information'] = $true
    Get-ChildItem "${letter}:\" -Force -ErrorAction SilentlyContinue |
        Where-Object { -not $expected.ContainsKey($_.Name.ToLower()) }
}

# ---------- XAML (dark modern UI) ----------
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:wfi="clr-namespace:System.Windows.Forms.Integration;assembly=WindowsFormsIntegration"
        xmlns:wf="clr-namespace:System.Windows.Forms;assembly=System.Windows.Forms"
        Title="CMU Mods" Width="940" Height="720" MinWidth="940" MinHeight="700"
        Background="#FF16161E" WindowStartupLocation="CenterScreen"
        FontFamily="Segoe UI" ResizeMode="CanResizeWithGrip">
  <Window.Resources>
    <Style x:Key="Card" TargetType="Border">
      <Setter Property="Background" Value="#FF21212C"/>
      <Setter Property="CornerRadius" Value="10"/>
      <Setter Property="Padding" Value="14"/>
      <Setter Property="Margin" Value="0,0,0,10"/>
    </Style>
    <Style x:Key="CardTitle" TargetType="TextBlock">
      <Setter Property="Foreground" Value="#FF7AB8F5"/>
      <Setter Property="FontSize" Value="13"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Margin" Value="0,0,0,8"/>
    </Style>
    <Style x:Key="Chk" TargetType="CheckBox">
      <Setter Property="Foreground" Value="#FFE8E8EE"/>
      <Setter Property="FontSize" Value="12"/>
      <Setter Property="Margin" Value="0,3"/>
      <Setter Property="Cursor" Value="Hand"/>
    </Style>
  </Window.Resources>
  <Grid Margin="18">
    <Grid.RowDefinitions>
      <RowDefinition Height="62"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <!-- Header -->
    <Grid Grid.Row="0">
      <StackPanel>
        <TextBlock x:Name="txtTitle" Text="CMU Mods" Foreground="White" FontSize="24" FontWeight="Bold"/>
        <TextBlock x:Name="txtSub" Foreground="#FF8A8F9D" FontSize="11" Margin="1,2,0,0"/>
      </StackPanel>
      <ComboBox x:Name="cmbLang" HorizontalAlignment="Right" VerticalAlignment="Center"
                Width="150" Padding="8,5" FontSize="12"/>
      <TextBlock x:Name="txtWarn" HorizontalAlignment="Right" VerticalAlignment="Bottom"
                 Margin="0,0,0,2" FontSize="10.5" Foreground="#FFFFB454" TextAlignment="Right"/>
    </Grid>

    <!-- Body: left options / right preview -->
    <Grid Grid.Row="1">
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="330"/>
      </Grid.ColumnDefinitions>

      <ScrollViewer Grid.Column="0" VerticalScrollBarVisibility="Auto" Margin="0,0,14,0">
        <StackPanel>
          <Border Style="{StaticResource Card}">
            <StackPanel>
              <TextBlock x:Name="txtDriveTitle" Style="{StaticResource CardTitle}"/>
              <Grid>
                <Grid.ColumnDefinitions>
                  <ColumnDefinition Width="*"/>
                  <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <ComboBox x:Name="cmbDrive" Padding="8,5" FontSize="12"/>
                <Button x:Name="btnRefresh" Grid.Column="1" Margin="8,0,0,0" Padding="14,5" FontSize="12"/>
              </Grid>
              <TextBlock x:Name="txtStatus" Foreground="#FF7FD07F" FontSize="11" Margin="2,8,2,0" TextWrapping="Wrap"/>
            </StackPanel>
          </Border>

          <Border Style="{StaticResource Card}" x:Name="cardMods">
            <StackPanel>
              <TextBlock x:Name="txtModsTitle" Style="{StaticResource CardTitle}"/>
              <Grid>
                <Grid.ColumnDefinitions>
                  <ColumnDefinition Width="*"/><ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <CheckBox x:Name="chkAA" IsChecked="True" Tag="chkAA" Style="{StaticResource Chk}">
                  <CheckBox.Content>
                    <StackPanel>
                      <TextBlock x:Name="chkAA1" Foreground="#FFE8E8EE" FontSize="12.5" FontWeight="SemiBold"/>
                      <TextBlock x:Name="chkAA2" Foreground="#FF8A8F9D" FontSize="10.5"/>
                    </StackPanel>
                  </CheckBox.Content>
                </CheckBox>
                <CheckBox x:Name="chkTT" Grid.Column="1" IsChecked="True" Tag="chkTT" Style="{StaticResource Chk}">
                  <CheckBox.Content>
                    <StackPanel>
                      <TextBlock x:Name="chkTT1" Foreground="#FFE8E8EE" FontSize="12.5" FontWeight="SemiBold"/>
                      <TextBlock x:Name="chkTT2" Foreground="#FF8A8F9D" FontSize="10.5"/>
                    </StackPanel>
                  </CheckBox.Content>
                </CheckBox>
              </Grid>
            </StackPanel>
          </Border>

          <Border Style="{StaticResource Card}" x:Name="cardAio">
            <StackPanel>
              <TextBlock x:Name="txtAioTitle" Style="{StaticResource CardTitle}"/>
              <UniformGrid x:Name="gridAio" Columns="2"/>
            </StackPanel>
          </Border>

          <Border Style="{StaticResource Card}" x:Name="cardOpt">
            <StackPanel>
              <TextBlock x:Name="txtOptTitle" Style="{StaticResource CardTitle}"/>
              <StackPanel x:Name="stackOpt"/>
            </StackPanel>
          </Border>
        </StackPanel>
      </ScrollViewer>

      <!-- Preview panel -->
      <Border Grid.Column="1" Style="{StaticResource Card}" Margin="0" x:Name="cardPrev">
        <StackPanel>
          <TextBlock x:Name="txtPrevTitle" Style="{StaticResource CardTitle}"/>
          <Border CornerRadius="8" ClipToBounds="True" Background="#FF16161E" Height="190">
            <Grid>
              <Image x:Name="imgPreview" Stretch="Uniform" StretchDirection="Both"/>
              <wfi:WindowsFormsHost x:Name="gifHost" Visibility="Collapsed">
                <wf:PictureBox x:Name="pbGif" Dock="Fill" SizeMode="Zoom" BackColor="#16161E"/>
              </wfi:WindowsFormsHost>
              <TextBlock x:Name="txtNoImg" Text="📷" FontSize="40" Foreground="#FF3A3F52"
                         HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Grid>
          </Border>
          <TextBlock x:Name="txtPrevName" Foreground="White" FontSize="13" FontWeight="SemiBold" Margin="2,10,2,4"/>
          <TextBlock x:Name="txtPrevDesc" Foreground="#FFB8BCC9" FontSize="11.5" TextWrapping="Wrap" Margin="2,0,2,0"/>
        </StackPanel>
      </Border>
    </Grid>

    <Button x:Name="btnWrite" Grid.Row="2" Margin="0,4,0,8" Height="42" FontSize="14" FontWeight="SemiBold">
      <Button.Style>
        <Style TargetType="Button">
          <Setter Property="Background" Value="#FF0078D7"/>
          <Setter Property="Foreground" Value="White"/>
          <Setter Property="Cursor" Value="Hand"/>
          <Setter Property="Template">
            <Setter.Value>
              <ControlTemplate TargetType="Button">
                <Border Background="{TemplateBinding Background}" CornerRadius="8">
                  <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
              </ControlTemplate>
            </Setter.Value>
          </Setter>
          <Style.Triggers>
            <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#FF1C8CEB"/></Trigger>
            <Trigger Property="IsEnabled" Value="False"><Setter Property="Background" Value="#FF3A3F52"/></Trigger>
          </Style.Triggers>
        </Style>
      </Button.Style>
    </Button>
    <TextBlock x:Name="txtOut" Grid.Row="3" Foreground="#FF7FD07F" FontSize="11.5" TextWrapping="Wrap" Margin="2,0,2,4"/>
    <TextBlock Grid.Row="4" HorizontalAlignment="Center" Margin="0,0,0,2">
      <Hyperlink x:Name="lnkTip"
                 Foreground="#FF7AB8F5" FontSize="11">
        <Run x:Name="lnkTipText"/>
      </Hyperlink>
    </TextBlock>
  </Grid>
</Window>
"@

$window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
function W($n) { $window.FindName($n) }

$chkAA = W 'chkAA'; $chkTT = W 'chkTT'
$chkAA1 = W 'chkAA1'; $chkAA2 = W 'chkAA2'
$chkTT1 = W 'chkTT1'; $chkTT2 = W 'chkTT2'
$cmbLang = W 'cmbLang'; $cmbDrive = W 'cmbDrive'
$txtStatus = W 'txtStatus'; $txtOut = W 'txtOut'
$btnWrite = W 'btnWrite'; $btnRefresh = W 'btnRefresh'
$imgPreview = W 'imgPreview'; $txtNoImg = W 'txtNoImg'
$gifHost = W 'gifHost'; $pbGif = W 'pbGif'
$txtPrevName = W 'txtPrevName'; $txtPrevDesc = W 'txtPrevDesc'

# ---------- Populate option checkboxes ----------
$script:aioBoxes = @{}
$aioKeys = @("aio1","aio2","aio3","aio4","aio5","aio6","aio7","aio8","aio9")
$aioDirs = @("01-menu-loop","02-list-loop","03-shorter-delay","04-no-beeps","05-no-disclaimer","06-camera-warning","07-diag-1sec","08-bigger-album-art","09-remove-dead-services")
for ($i=0; $i -lt $aioKeys.Count; $i++) {
    $cb = New-Object System.Windows.Controls.CheckBox
    $cb.Tag = $aioKeys[$i]; $cb.IsChecked = $true
    $cb.Style = $window.FindResource('Chk')
    (W 'gridAio').Children.Add($cb) | Out-Null
    $script:aioBoxes[$aioDirs[$i]] = $cb
}

$script:optBoxes = @{}
$optKeys = @("opt_touch","opt_hud","opt_v16","opt_lat","opt_mute","opt_block","opt_unmute","opt_street","opt_btshow","opt_btbyp")
$optConf = @("touch","hud","use_protocol_v1_6","aa_audio_low_latency","mute_pauses_phone","block_headunit_media_play","unmute_starts_playback","force_street_name","bt_pairing_show_device_notification","bt_pairing_bypass_all_devices")
$optDef  = @($true,$true,$true,$true,$true,$true,$false,$false,$false,$false)
for ($i=0; $i -lt 10; $i++) {
    $cb = New-Object System.Windows.Controls.CheckBox
    $cb.Tag = $optKeys[$i]; $cb.IsChecked = $optDef[$i]
    $cb.Style = $window.FindResource('Chk')
    (W 'stackOpt').Children.Add($cb) | Out-Null
    $script:optBoxes[$optConf[$i]] = $cb
}

# ---------- Preview on hover ----------
$script:imgMap = @{ 'chkTT' = 'touchtune.png' }
function Get-TipKey($tag) {
    switch -Regex ($tag) {
        '^chk'  { return "tip_$tag" }
        '^aio'  { return "tip_$tag" }
        default { return "tip_" + ($tag -replace '^opt_','') }
    }
}
function Show-Preview($ctl) {
    $key = Get-TipKey $ctl.Tag
    $txtPrevName.Text = $ctl.Content.ToString()
    if ($ctl.Tag -eq 'chkAA') { $txtPrevName.Text = T 'chkAA' }
    if ($ctl.Tag -eq 'chkTT') { $txtPrevName.Text = T 'chkTT' }
    $txtPrevDesc.Text = T $key
    $img = $script:imgMap[$ctl.Tag]
    $imgPath = if ($img) { Join-Path $ImgDir $img } else { $null }
    if ($imgPath -and (Test-Path $imgPath)) {
        if ([IO.Path]::GetExtension($imgPath) -eq '.gif') {
            # Animated GIF -> hosted WinForms PictureBox (WPF Image can't animate)
            if ($pbGif.Image) { $pbGif.Image.Dispose() }
            $pbGif.Image = [System.Drawing.Image]::FromFile($imgPath)
            $imgPreview.Source = $null
            $imgPreview.Visibility = 'Collapsed'
            $gifHost.Visibility = 'Visible'
        } else {
            $bmp = New-Object System.Windows.Media.Imaging.BitmapImage
            $bmp.BeginInit(); $bmp.UriSource = $imgPath; $bmp.EndInit()
            $imgPreview.Source = $bmp
            $imgPreview.Visibility = 'Visible'
            $gifHost.Visibility = 'Collapsed'
        }
        $txtNoImg.Visibility = 'Collapsed'
    } else {
        $imgPreview.Source = $null
        $gifHost.Visibility = 'Collapsed'
        $imgPreview.Visibility = 'Visible'
        $txtNoImg.Visibility = 'Visible'
    }
}
function Clear-Preview {
    $txtPrevName.Text = ""
    $txtPrevDesc.Text = T 'hoverhint'
    $imgPreview.Source = $null
    $imgPreview.Visibility = 'Visible'
    $gifHost.Visibility = 'Collapsed'
    $txtNoImg.Visibility = 'Visible'
}
foreach ($ctl in @($chkAA, $chkTT) + @((W 'gridAio').Children) + @((W 'stackOpt').Children)) {
    $ctl.Add_MouseEnter({ Show-Preview $this })
    $ctl.Add_MouseLeave({ Clear-Preview })
}

# ---------- Localization ----------
# Windows cannot render flag emojis -> use real PNG flags from images/
function Add-LangItem($flagFile, $text) {
    $item = New-Object System.Windows.Controls.ComboBoxItem
    $sp = New-Object System.Windows.Controls.StackPanel
    $sp.Orientation = 'Horizontal'
    $img = New-Object System.Windows.Controls.Image
    $imgPath = Join-Path $ImgDir $flagFile
    if (Test-Path $imgPath) {
        $bmp = New-Object System.Windows.Media.Imaging.BitmapImage
        $bmp.BeginInit(); $bmp.UriSource = $imgPath; $bmp.EndInit()
        $img.Source = $bmp
    }
    $img.Height = 14; $img.Margin = "0,0,8,0"; $img.VerticalAlignment = 'Center'
    $tb = New-Object System.Windows.Controls.TextBlock
    $tb.Text = $text; $tb.VerticalAlignment = 'Center'
    $sp.Children.Add($img) | Out-Null
    $sp.Children.Add($tb) | Out-Null
    $item.Content = $sp
    $cmbLang.Items.Add($item) | Out-Null
}
Add-LangItem 'flag-gb.png' 'English'
Add-LangItem 'flag-fr.png' 'Francais'
Add-LangItem 'flag-de.png' 'Deutsch'
Add-LangItem 'flag-es.png' 'Espanol'
Add-LangItem 'flag-cn.png' '中文'
$cmbLang.SelectedIndex = 0

function Set-Language {
    if ($script:capMode) {
        $window.Title    = "CMU Screen Capture"
        (W 'txtTitle').Text = "CMU Capture"
        (W 'txtSub').Text   = "Screen capture key - records the CMU display to GIF"
    } else {
        $window.Title     = T 'title'
        (W 'txtTitle').Text  = T 'title'
        (W 'txtSub').Text    = T 'subtitle'
    }
    (W 'txtDriveTitle').Text = "💾  " + (T 'drive')
    $btnRefresh.Content = T 'refresh'
    (W 'txtModsTitle').Text = "🧩  " + (T 'grpMods')
    $chkAA1.Text = T 'chkAA'; $chkAA2.Text = T 'chkAAsub'
    $chkTT1.Text = T 'chkTT'; $chkTT2.Text = T 'chkTTsub'
    (W 'txtAioTitle').Text = "🎛️  " + (T 'grpAio')
    (W 'txtOptTitle').Text = "⚙️  " + (T 'grpOpt')
    (W 'txtPrevTitle').Text = "🔍  " + (T 'preview')
    foreach ($cb in (W 'gridAio').Children) { $cb.Content = T $cb.Tag }
    foreach ($cb in (W 'stackOpt').Children) { $cb.Content = T $cb.Tag }
    $btnWrite.Content = T 'write'
    (W 'txtWarn').Text = T 'warnfw'
    (W 'lnkTipText').Text = T 'tiplink'
    Clear-Preview
    if ($script:drives.Count -eq 0) { $txtStatus.Text = T 'nodrive' }
    elseif ($cmbDrive.SelectedIndex -ge 0) { Update-DriveStatus }
}
$cmbLang.Add_SelectionChanged({
    switch ($cmbLang.SelectedIndex) {
        0 {$script:lang='en'} 1 {$script:lang='fr'} 2 {$script:lang='de'}
        3 {$script:lang='es'} 4 {$script:lang='zh'}
    }
    Set-Language
})

# ---------- Drive logic ----------
$script:drives = @()
function Refresh-Drives {
    $script:drives = @(Get-UsbDrives)
    $cmbDrive.Items.Clear()
    foreach ($d in $script:drives) {
        $cmbDrive.Items.Add("$($d.Letter):  $($d.Label)  $($d.FS)  $($d.SizeGB) GB  [$($d.Style)]") | Out-Null
    }
    if ($cmbDrive.Items.Count -gt 0) { $cmbDrive.SelectedIndex = 0 }
    else {
        $txtStatus.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFrom('#FFFF6B6B')
        $txtStatus.Text = T 'nodrive'
    }
}
function Update-DriveStatus {
    $d = $script:drives[$cmbDrive.SelectedIndex]
    if (-not $d) { return }
    $problems = Test-Drive $d
    $ups = @(Get-RootUpFiles $d.Letter)
    if ($ups.Count -gt 1) {
        $problems += "$(T 'dupup') : " + (($ups | ForEach-Object { $_.Name }) -join ", ")
    }
    $bc = [System.Windows.Media.BrushConverter]::new()
    if ($problems.Count -eq 0) {
        $extra = ""
        $stray = @(Get-StrayRootItems $d.Letter)
        if ($stray.Count -gt 0) {
            $names = ($stray | ForEach-Object { $_.Name }) -join ", "
            if ($names.Length -gt 60) { $names = $names.Substring(0,60) + "..." }
            $extra = "`n$(T 'stray') : $names"
        }
        $txtStatus.Foreground = $bc.ConvertFrom('#FF7FD07F')
        $txtStatus.Text = "$(T 'okdrive')  $($d.SizeGB) GB$extra"
        $btnWrite.IsEnabled = $true
    } else {
        $txtStatus.Foreground = $bc.ConvertFrom('#FFFF6B6B')
        $txtStatus.Text = "$(T 'nocmp') :`n" + ($problems -join "`n")
        $formatIssue = $problems | Where-Object { $_ -match [regex]::Escape((T 'badfs')) -or $_ -match [regex]::Escape((T 'badstyle')) -or $_ -match [regex]::Escape((T 'badsize')) }
        if ($formatIssue) { $txtStatus.Text += "`n" + (T 'fixhint') }
        $btnWrite.IsEnabled = $false
    }
}
$cmbDrive.Add_SelectionChanged({ Update-DriveStatus })
$btnRefresh.Add_Click({ Refresh-Drives })

# ---------- Write ----------
$btnWrite.Add_Click({
    $d = $script:drives[$cmbDrive.SelectedIndex]
    if (-not $d) { return }
    $dest = "$($d.Letter):\"

    # Firmware version warning: install package only supports 74.00.324
    # (the capture tool does not depend on firmware version)
    if (-not $script:capMode) {
        $fwRes = [System.Windows.Forms.MessageBox]::Show((T 'askfw'), (T 'title'), "YesNo", "Warning")
        if ($fwRes -ne 'Yes') { return }
    }
    $bc = [System.Windows.Media.BrushConverter]::new()

    $anyAio = $false
    foreach ($m in $script:aioBoxes.Keys) { if ($script:aioBoxes[$m].IsChecked) { $anyAio = $true } }
    if (-not $chkAA.IsChecked -and -not $chkTT.IsChecked -and -not $anyAio) {
        [System.Windows.Forms.MessageBox]::Show((T 'pickone'), (T 'nothing'), "OK", "Warning") | Out-Null
        return
    }

    $ourUp = Get-OurUpName
    $strayUps = @(Get-RootUpFiles $d.Letter | Where-Object { $_.Name -ne $ourUp })
    if ($strayUps.Count -gt 0) {
        $names = ($strayUps | ForEach-Object { $_.Name }) -join "`n"
        $res = [System.Windows.Forms.MessageBox]::Show((T 'askclean' -f $names), (T 'conflict'), "YesNo", "Warning")
        if ($res -ne 'Yes') { return }
    }

    try {
        $txtOut.Foreground = $bc.ConvertFrom('#FFB8BCC9'); $txtOut.Text = T 'copying'
        [System.Windows.Forms.Application]::DoEvents()

        foreach ($f in $strayUps) { Remove-Item $f.FullName -Force }

        $rc = robocopy "$SrcDir" "$dest" /E /NFL /NDL /NJH /NJS /NP | Out-String
        if ($LASTEXITCODE -gt 7) { throw "robocopy failed (code $LASTEXITCODE)" }

        # Normalize line endings to LF on the drive (CMU shell breaks on CRLF)
        $textExt = '\.(sh|txt|cfg|conf|xml|js|css|html|up)$'
        Get-ChildItem $dest -Recurse -File |
            Where-Object { $_.Name -match $textExt -or $_.Name -in @('jci-autoupdate','LICENSE','NOTICE','VERSION','LAUNCHER.NAME','TOUCHTUNE.ID','PAYLOAD.SHA256','SOURCE.txt') } |
            ForEach-Object {
                $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
                $clean = New-Object System.Collections.Generic.List[byte]
                for ($i=0; $i -lt $bytes.Length; $i++) {
                    if ($bytes[$i] -eq 13 -and $i+1 -lt $bytes.Length -and $bytes[$i+1] -eq 10) { continue }
                    $clean.Add($bytes[$i])
                }
                if ($clean.Count -ne $bytes.Length) { [System.IO.File]::WriteAllBytes($_.FullName, $clean.ToArray()) }
            }

        if ($script:capMode) {
            # Capture key: only files + one .up, no MODS.cfg / module logic
            $finalUps = @(Get-RootUpFiles $d.Letter)
            if ($finalUps.Count -ne 1) { throw "Post-write check failed: $($finalUps.Count) .up file(s) at root" }
            $txtOut.Foreground = $bc.ConvertFrom('#FF7FD07F')
            $txtOut.Text = T 'done'
            return
        }

        if (-not $chkTT.IsChecked -and (Test-Path "${dest}touchtune")) {
            Remove-Item "${dest}touchtune" -Recurse -Force
        }

        $mods = @()
        $mods += "LANG=$script:lang"
        $mods += "MOD_OEM_AA=" + $(if ($chkAA.IsChecked) { "1" } else { "0" })
        $mods += "MOD_TOUCHTUNE=" + $(if ($chkTT.IsChecked) { "1" } else { "0" })
        foreach ($mod in $script:aioBoxes.Keys) {
            $flag = "MOD_AIO_" + ($mod -replace '-','_').ToUpper()
            $mods += "$flag=" + $(if ($script:aioBoxes[$mod].IsChecked) { "1" } else { "0" })
        }
        [System.IO.File]::WriteAllText("${dest}MODS.cfg", (($mods -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding $false))

        # Inject the support link into run.sh's end-of-install message
        $rsPath = "${dest}run.sh"
        if (Test-Path $rsPath) {
            $tipHost = ($TipUrl -replace '^https?://','').TrimEnd('/')
            $rs = [System.IO.File]::ReadAllText($rsPath)
            $rs = $rs -replace 'ko-fi\.com/fuxio11', $tipHost
            [System.IO.File]::WriteAllText($rsPath, $rs, (New-Object System.Text.UTF8Encoding $false))
        }

        foreach ($mod in $script:aioBoxes.Keys) {
            $mpath = "${dest}aio\$mod"
            if (-not $script:aioBoxes[$mod].IsChecked -and (Test-Path $mpath)) {
                Remove-Item $mpath -Recurse -Force
            }
        }

        if ($chkAA.IsChecked) {
            $confPath = "${dest}resources\libpatch.conf"
            $conf = Get-Content $confPath -Raw
            foreach ($key in $script:optBoxes.Keys) {
                $val = if ($script:optBoxes[$key].IsChecked) { "true" } else { "false" }
                $conf = [regex]::Replace($conf, "(?m)^\s*$([regex]::Escape($key))\s*=\s*\w+", "$key = $val")
            }
            [System.IO.File]::WriteAllText($confPath, $conf, (New-Object System.Text.UTF8Encoding $false))
        }

        $finalUps = @(Get-RootUpFiles $d.Letter)
        if ($finalUps.Count -ne 1 -or $finalUps[0].Name -ne $ourUp) {
            throw "Post-write check failed: $($finalUps.Count) .up file(s) at root"
        }

        $extra = ""
        if ($strayUps.Count -gt 0) { $extra = "`n" + (T 'cleaned') }
        $txtOut.Foreground = $bc.ConvertFrom('#FF7FD07F')
        $txtOut.Text = (T 'done') + $extra
    } catch {
        $txtOut.Foreground = $bc.ConvertFrom('#FFFF6B6B')
        $txtOut.Text = "$(T 'err') : $($_.Exception.Message)"
    }
})

$chkAA.Add_Checked({ (W 'cardOpt').IsEnabled = $true })
$chkAA.Add_Unchecked({ (W 'cardOpt').IsEnabled = $false })

# ---------- Capture mode: hide everything module-related ----------
if ($script:capMode) {
    foreach ($c in @('cardMods','cardAio','cardOpt','cardPrev')) {
        (W $c).Visibility = 'Collapsed'
    }
    $window.Width = 560; $window.MinWidth = 560
    $window.Title = "CMU Screen Capture"
    $txtWarn.Visibility = 'Collapsed'
    $script:capModeTitle = $true
}

Set-Language
Refresh-Drives
(W 'lnkTip').NavigateUri = $TipUrl
(W 'lnkTip').Add_RequestNavigate({ param($s,$e) Start-Process $e.Uri.AbsoluteUri; $e.Handled = $true })
[void]$window.ShowDialog()
