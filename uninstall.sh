#!/data/data/com.termux/files/usr/bin/sh

echo "Deleting files and directories related to the project..."
rm -rf ~/tmp.wav ~/pulseaudio-without-memfd.deb ~/.termux/boot/wyoming-satellite-android ~/wyoming-satellite

echo "Uninstalling custom pulseaudio build if it is installed..."
if command -v pulseaudio > /dev/null 2>&1; then
    export ARCH="$(termux-info | grep -A 1 "CPU architecture:" | tail -1)" 
    echo "Architecture: $ARCH"
    if [ "$ARCH" = "arm" ] ; then
        pkg remove -y pulseaudio
    fi
fi

echo "Done"
