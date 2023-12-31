#!/bin/bash
# Copyright 2023 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

# Script to flash a sonoff device manually over serial when it's cracked open.

set -eu

cd "$(dirname $0)"
cd ..
if [ ! -f .venv/bin/activate ]; then
  echo "run setup.sh"
  exit 1
fi

if [ $# != 1 ]; then
  echo "Usage: $0 foo.yaml"
  exit 1
fi

source .venv/bin/activate

name=$(echo $1 | cut -f 1 -d '.')
firmware=out/$name/.pioenvs/$name/firmware.bin
comport=/dev/ttyUSB0

if [ ! -f $firmware ]; then
  esphome $1 compile
fi

echo ""
echo "Now hold the button, then connect the 4 pins: Vcc, Gnd, RX and TX"
echo ""
echo "Sleeping for 3 seconds"
sleep 3

.venv/bin/esptool.py \
  --before default_reset \
  --after hard_reset \
  --baud 115200 \
  --chip esp8266 \
  --port $comport \
  write_flash 0x0 \
  $firmware 
