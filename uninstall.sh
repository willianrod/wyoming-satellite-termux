#!/data/data/com.termux/files/usr/bin/sh

echo "Deleting files and directories related to the project..."
rm -f ~/tmp.wav
rm -f ~/pulseaudio-without-memfd.deb 
rm -rf ~/.termux/boot/wyoming-satellite-android 
rm -rf ~/wyoming-satellite
rm -rf ~/wyoming-openwakeword

echo "Uninstalling custom pulseaudio build if it is installed..."
if command -v pulseaudio > /dev/null 2>&1; then
    export ARCH="$(termux-info | grep -A 1 "CPU architecture:" | tail -1)" 
    echo "Architecture: $ARCH"
    if [ "$ARCH" = "arm" ] ; then
        pkg remove -y pulseaudio
    fi
fi

echo "Done"
