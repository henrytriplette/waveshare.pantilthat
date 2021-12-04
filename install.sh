#!/bin/bash

ver="0.81"

INSTALL_DIR='waveshare'  # Default folder install location

cd ~
is_upgrade=false
if [ -d "$INSTALL_DIR" ] ; then
  STATUS="Upgrade"
  is_upgrade=true
else
  STATUS="New Install"
  mkdir -p $INSTALL_DIR
  echo "$STATUS Created Folder $INSTALL_DIR"
fi

# Remember where this script was launched from
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $INSTALL_DIR
INSTALL_PATH=$( pwd )
echo "-----------------------------------------------"
echo "$STATUS panosend-install.sh ver $ver"
echo "-----------------------------------------------"
echo "$STATUS Download GitHub Files"
if $is_upgrade ; then
    installFiles=("pantilthat.py" "test-pantilt.py" "sinwave-dance.py")
else
    installFiles=("pantilthat.py" "test-pantilt.py" "sinwave-dance.py")
fi

for fname in "${installFiles[@]}" ; do
    wget_output=$(wget -O $fname -q --show-progress https://raw.githubusercontent.com/henrytriplette/waveshare.pantilthat/main/$fname)
    if [ $? -ne 0 ]; then
        if [ $? -ne 0 ]; then
            echo "ERROR - $fname wget Download Failed. Possible Cause Internet Problem."
        else
            wget -O $fname https://raw.githubusercontent.com/henrytriplette/waveshare.pantilthat/main/$fname
        fi
    fi
done

chmod +x *py

# create python library module folders for python3
sudo mkdir -p /usr/lib/python3/dist-packages/waveshare
sudo cp pantilthat.py /usr/lib/python3/dist-packages/waveshare
sudo touch /usr/lib/python3/dist-packages/waveshare/__init__.py
rm pantilthat.py

echo "$STATUS Install Dependencies"
sudo apt-get -yq install python-rpi.gpio
sudo apt-get -yq install python-picamera

bcm_ver='71'
cd ~
echo "$0 Install bcm2835-1.$bcm_ver  Please wait ..."
echo "$0 Downloading http://www.airspayce.com/mikem/bcm2835/bcm2835-1.$bcm_ver.tar.gz"
wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.$bcm_ver.tar.gz
tar -zxvf bcm2835-1.$bcm_ver.tar.gz
cd bcm2835-1.$bcm_ver
sudo ./configure
echo "$0 Compiling ..... One Moment Please"
sudo make
sudo make check
echo "$0 Running make install"
sudo make install
echo "$0 Performing Cleanup"
cd ~
rm bcm2835-1.$bcm_ver.tar.gz
sudo rm -r  bcm2835-1.$bcm_ver
echo "$0 Completed Install of bcm2835-1.$bcm_ver"
echo "
-----------------------------------------------
$STATUS Complete
-----------------------------------------------
INSTRUCTIONS Assumes you are comfortable with SSH and/or Terminal session commands

1. Ensure picamera module is enabled, connected and working.
2. Ensure waveshare pantilt hardware is assembled and connected to the Raspberry Pi
3. Ensure I2C and picamera are Enabled using raspi-config whiptail menu system.

    sudo raspi-config

Using whiptail menu select Interfacing then I2C and Enable.
Also ensure the picamera module is Enabled.

4. Reboot RPI

Run demo per the following commands

    cd ~/waveshare
    ./test-pantilt.py
    ./sinwave-dance.py

Good Luck Claude ...
Bye"
