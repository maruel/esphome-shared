#!/bin/bash
# Copyright 2023 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

# Initial setup.

set -eu

cd "$(dirname $0)"
cd ..

# Set it to -v for verbosity.
QUIET=-q

if [ ! -f /usr/bin/apg ]; then
  echo "Installing apg"
  sudo apt install -y apg
fi

if [ ! -f /usr/share/doc/libpython3-dev/README.Debian ]; then
  echo "Installing libpython3-dev"
  sudo apt install -y libpython3-dev
fi

if [ ! -d /usr/share/doc/libffi-dev ]; then
  echo "Installing libffi-dev"
  sudo apt install -y libffi-dev
fi

if [ ! -f /usr/share/doc/python3-distutils/README.Debian ]; then
  echo "Installing python3-distutils"
  sudo apt install -y python3-distutils
fi

# Because of
# https://github.com/platformio/platform-espressif32/blob/HEAD/builder/frameworks/espidf.py
# TODO(maruel): The version will be stale.
if [ ! -f /usr/lib/python3.10/ensurepip/__init__.py ]; then
  sudo apt install -y python3.10-venv
fi

GROUP_ADDED=0
if ! groups | grep -q dialout; then
  sudo usermod -a -G dialout $USER
  GROUP_ADDED=1
fi

# Ask the user to enter the wifi SSID and password.
if [ ! -f secrets.yaml ]; then
  cat <<EOF >secrets.yaml
ota_password="$(apg -M CLN -m 8 -n 1)"
ota_password="$(apg -M CLN -m 8 -n 1)"

# Please enter the wifi SSID and password:
wifi_ssid: "WIFI_SSID"
wifi_pass: "WIFI_PASS"
EOF
  nano secrets.yaml
fi

if [ -f .venv/bin/esphome ]; then
  exit 0
fi

if [ ! -d .venv ]; then
  mkdir .venv
fi

if [ ! -f ./.venv/bin/activate ]; then
  VIRTUALENV="$(which virtualenv || true)"
  if [ "$VIRTUALENV" = "" ]; then
    echo "- Getting virtualenv"
    wget --quiet https://bootstrap.pypa.io/virtualenv.pyz -O virtualenv.pyz
    #curl -SLs https://bootstrap.pypa.io/virtualenv.pyz > virtualenv.pyz
    echo "- Creating virtualenv"
    # Fails on python 3.4 to 3.6 is the path is not absolute.
    python3 "$(pwd)/virtualenv.pyz" $QUIET .venv
    rm virtualenv.pyz
  else
    # Reuse the preinstalled virtualenv tool if it exists.
    echo "- Creating virtualenv"
    $VIRTUALENV $QUIET .venv
  fi
fi

echo "- Activating virtualenv"
source ./.venv/bin/activate

echo "- Installing requirements"
pip install $QUIET -U -r esphome-shared/requirements.txt

# Stop platformio from checking the internet at every single goddam invocation.
platformio settings set enable_telemetry No
#platformio settings set check_libraries_interval 1000000
platformio settings set check_platformio_interval 1000000
#platformio settings set check_platforms_interval 1000000

echo ""
echo "Congratulations! Everything is inside ./.venv/"
echo "To access esphome, run:"
echo "  source ./.venv/bin/activate"
if [ "$GROUP_ADDED" = "1" ]; then
  echo ""
  echo "Dang, I just added access to the USB port. If you need"
  echo "to flash via USB, you need to reboot"
fi
