#!/bin/bash
# Copyright 2023 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

# Initial setup.

set -eu

cd "$(dirname $0)/.."

# Set it to -v for verbosity.
QUIET=-q

if [ ! -f /usr/bin/apg ]; then
  echo "- Installing apg"
  sudo apt install -y -q -q apg
fi

if [ ! -f /usr/share/doc/libpython3-dev/README.Debian ]; then
  echo "- Installing libpython3-dev"
  sudo apt install -y -q -q libpython3-dev
fi

if [ ! -d /usr/share/doc/libffi-dev ]; then
  echo "- Installing libffi-dev"
  sudo apt install -y -q -q libffi-dev
fi

if [ ! -f /usr/share/doc/python3-distutils/README.Debian ]; then
  echo "- Installing python3-distutils"
  sudo apt install -y -q -q python3-distutils
fi

# Because of
# https://github.com/platformio/platform-espressif32/blob/HEAD/builder/frameworks/espidf.py
# TODO(maruel): The version will be stale.
SYSTEM_PYTHON=$(python3 -c "import sys; print(f'python{sys.version_info[0]}.{sys.version_info[1]}')")
if [ ! -f /usr/lib/$SYSTEM_PYTHON/ensurepip/__init__.py ]; then
  echo "- Installing $SYSTEM_PYTHON-venv"
  sudo apt install -y -q $SYSTEM_PYTHON-venv
fi

GROUP_ADDED=0
if ! groups | grep -q dialout; then
  echo "- Add $USER to dialout to allow flashing via USB serial"
  sudo usermod -a -G dialout $USER
  GROUP_ADDED=1
fi

# Ask the user to enter the wifi SSID and password.
if [ ! -f secrets.yaml ]; then
  cat <<EOF >secrets.yaml
# Password to connect when Wifi cannot be found.
ap_password: "$(apg -M CLN -m 8 -n 1)"
# Password to update over-the-air.
ota_password: "$(apg -M CLN -m 8 -n 1)"

# Please enter the wifi SSID and password:
wifi_ssid: "WIFI_SSID"
wifi_pass: "WIFI_PASS"
EOF
  vim secrets.yaml
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

# Install ESPHome Dashboard
mkdir -p ~/.config/systemd/user
cp esphome-shared/rsc/*.service ~/.config/systemd/user
systemctl --user daemon-reload
systemctl --user enable esphome-dashboard
systemctl --user restart esphome-dashboard

echo ""
echo "Congratulations! Everything is inside ./.venv/"
echo "To access esphome, run:"
echo "  source ./.venv/bin/activate"
if [ "$GROUP_ADDED" = "1" ]; then
  echo ""
  echo "Dang, I just added access to the USB port. If you need"
  echo "to flash via USB, you need to reboot."
fi
