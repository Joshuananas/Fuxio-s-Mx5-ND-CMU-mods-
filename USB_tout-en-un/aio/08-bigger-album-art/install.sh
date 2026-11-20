. "$(dirname "$0")/../_common.sh"
CSS=/jci/gui/common/controls/NowPlaying4/css/NowPlaying4Ctrl.css
modlog "install bigger album art"
bak_file "$CSS"
cp -a "${MYDIR}/files/images/InCall2.png" /jci/gui/common/controls/InCall2/images/NowPlayingImageFrame.png
cp -a "${MYDIR}/files/images/NowPlaying4.png" /jci/gui/common/controls/NowPlaying4/images/NowPlayingImageFrame.png
sed -i '/MZD-AIO-TI BIGGERALBM/,/END AIO BIGGERALBM/d' "$CSS"
echo "/* MZD-AIO-TI BIGGERALBM CSS */" >> "$CSS"
cat "${MYDIR}/files/big-albm.css" >> "$CSS"
echo "/* END AIO BIGGERALBM CSS */" >> "$CSS"
