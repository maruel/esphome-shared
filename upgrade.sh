#!/bin/bash
# Copyright 2023 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

# Upgrades esphome and its dependencies.

set -eu

cd "$(dirname $0)"
cd ..
if [ ! -f .venv/bin/activate ]; then
  echo "run setup.sh"
  exit 1
fi

source .venv/bin/activate
pip install -U pip
pip install -U esphome

# For fonts support.
pip install -U pillow

# Security updates as per
# https://github.com/maruel/esphome-shared/security/dependabot
pip install -U cryptography">=41.0.6"
pip install -U esptool">4.6.2"
pip install -U urllib3">=2.0.7"

# Freeze and diff
pip freeze > esphome-shared/requirements.txt
git diff esphome-shared/requirements.txt
echo "See https://github.com/esphome/esphome/releases/ for changes."
