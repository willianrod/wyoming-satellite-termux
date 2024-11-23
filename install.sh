#!/data/data/com.termux/files/usr/bin/sh

echo "Enter home directory"
cd ~

echo "Update packages and index"
pkg up

echo "Ensure wget is available..."
if ! command -v wget > /dev/null 2>&1; then
    echo "Installing wget..."
    pkg install wget -y
    if ! command -v wget > /dev/null 2>&1; then
        echo "ERROR: Failed to install wget" >&2
        exit 1
    fi
fi

echo "Clean up potential garbage that might otherwise get in the way..."
wget -qO- https://raw.githubusercontent.com/T-vK/wyoming-satellite-termux/refs/heads/main/uninstall.sh | bash

echo "Ensure sox is available..."
if ! command -v rec > /dev/null 2>&1; then
    echo "Installing sox..."
    pkg install sox -y
    if ! command -v rec > /dev/null 2>&1; then
        echo "ERROR: Failed to install sox (rec not found)" >&2
        exit 1
    fi
    if ! command -v play > /dev/null 2>&1; then
        echo "ERROR: Failed to install sox (play not found)" >&2
        exit 1
    fi
fi

echo "Ensure termux-api is available..."
if ! command -v termux-microphone-record > /dev/null 2>&1; then
    echo "Installing termux-api..."
    pkg install termux-api -y
    if ! command -v termux-microphone-record > /dev/null 2>&1; then
        echo "ERROR: Failed to install termux-api (termux-microphone-record not found)" >&2
        exit 1
    fi
fi

echo "Checking if Linux kernel supports memfd..."
KERNEL_MAJOR_VERSION="$(uname -r | awk -F'.' '{print $1}')"
if [ $KERNEL_MAJOR_VERSION -le 3 ]; then
    echo "Your kernel is too old to support memfd."
    echo "Installing a custom build of pulseaudio that doesn't depend on memfd..."
    export ARCH="$(termux-info | grep -A 1 "CPU architecture:" | tail -1)"
    echo "Checking if pulseaudio is currently installed..."
    if command -v pulseaudio > /dev/null 2>&1; then
        echo "Uninstalling pulseaudio..."
        pkg remove pulseaudio -y
    fi
    echo "Downloading pulseaudio build that doesn't require memfd..."
    wget -O ./pulseaudio-without-memfd.deb "https://github.com/T-vK/pulseaudio-termux-no-memfd/releases/download/1.1.0/pulseaudio_17.0-2_${ARCH}.deb"
    echo "Installing the downloaded pulseaudio build..."
    pkg install ./pulseaudio-without-memfd.deb -y
    echo "Removing the downloaded pulseaudio build (not required after installation)..."
    rm -f ./pulseaudio-without-memfd.deb
else
    if ! command -v pulseaudio > /dev/null 2>&1; then
        pkg install pulseaudio -y
    fi
fi

if ! command -v pulseaudio > /dev/null 2>&1; then
    echo "ERROR: Failed to install pulseaudio..." >&2
    exit 1
fi

echo "Starting test recording to trigger mic permission prompt..."
echo "(It might ask you for mic access now. Select 'Always Allow'.)"
termux-microphone-record -f ./tmp.wav

echo "Quitting the test recording..."
termux-microphone-record -q

echo "Deleting the test recording..."
rm -f ./tmp.wav

echo "Temporarily load PulseAudio module for mic access..."
if ! pactl list short modules | grep "module-sles-source" ; then
    if ! pactl load-module module-sles-source; then
        echo "ERROR: Failed to load module-sles-source" >&2
    fi
fi

echo "Verify that there is at least one microphone detected..."
if ! pactl list short sources | grep "module-sles-source.c" ; then
    echo "ERROR: No microphone detected" >&2
fi

echo "Ensure git is available..."
if ! command -v git > /dev/null 2>&1; then
    echo "Installing git..."
    pkg install git -y
    if ! command -v git > /dev/null 2>&1; then
        echo "ERROR: Failed to install git" >&2
        exit 1
    fi
fi

echo "Cloning Wyoming Satellite repo..."
git clone https://github.com/rhasspy/wyoming-satellite.git

echo "Enter wyoming-satellite directory..."
cd wyoming-satellite

echo "Running Wyoming Satellite setup script..."
./script/setup
cd ..

echo "Write down the IP address (most likely starting with '192.') of your device, you should find it in the following output:"
ifconfig

echo "Setting up autostart..."
mkdir -p ~/.termux/boot/
wget -P ~/.termux/boot/ "https://raw.githubusercontent.com/T-vK/wyoming-satellite-termux/refs/heads/main/wyoming-satellite-android"
chmod +x ~/.termux/boot/wyoming-satellite-android

echo "Setting up widget shortcut..."
mkdir -p ~/.shortcuts/tasks/
ln -s ../../.termux/boot/wyoming-satellite-android ./wyoming-satellite-android


echo "Successfully installed and set up Wyoming Satellite"
echo "Install Wyoming OpenWakeWord as well? [y/N]"
read install_oww
if [ "$install_oww" = "y" ] || [ "$install_oww" = "Y" ]; then
    echo "Ensure python-tflite-runtime, ninja and patchelf are installed..."
    pkg install python-tflite-runtime ninja patchelf -y
    echo "Cloning Wyoming OpenWakeWord repo..."
    cd ~
    git clone https://github.com/rhasspy/wyoming-openwakeword.git
    echo "Enter wyoming-openwakeword directory..."
    cd wyoming-openwakeword
    echo "Allow system site packages in Wyoming OpenWakeWord setup script..."
    sed -i 's/\(builder = venv.EnvBuilder(with_pip=True\)/\1, system_site_packages=True/' ./script/setup
    echo "Running Wyoming OpenWakeWord setup script..."
    ./script/setup
    sed -i 's/^export OWW_ENABLED=false$/export OWW_ENABLED=true/' ~/.termux/boot/wyoming-satellite-android
    cd ..
    echo "Launch Wyoming OpenWakeWord and Wyoming Satellite now? [y/N]"
else
    echo "Launch Wyoming Satellite now? [y/N]"
fi

read launch_now
if [ "$launch_now" = "y" ] || [ "$launch_now" = "Y" ]; then
    echo "Starting it now..."
    ~/.termux/boot/wyoming-satellite-android
fi