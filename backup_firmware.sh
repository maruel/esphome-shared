#!/bin/bash
# Copyright 2023 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

# Backup a firmware, in case something breaks down.

set -eu

cd "$(dirname $0)"
cd ..

source .venv/bin/activate
comport=/dev/ttyUSB0
.venv/bin/esptool.py \
  --baud 115200 \
  --port $comport \
  read_flash 0x0 0x400000 \
  flash_4m.bin

#  read_flash 0x0 0x100000 \
#  flash_1m.bin

# For flashing, use: write_flash --flash_freq 80m 0x0
  #--chip esp8266 \
