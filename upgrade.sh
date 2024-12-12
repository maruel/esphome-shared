#!/bin/bash
# Copyright 2023 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

# Upgrades esphome and its dependencies.

set -eu

cd "$(dirname $0)/.."
if [ ! -f .venv/bin/activate ]; then
  echo "run setup.sh"
  exit 1
fi

source .venv/bin/activate
pip install -U pip
pip install -U esphome esphome-dashboard pillow

# Freeze and diff
pip freeze > esphome-shared/requirements.txt
git diff esphome-shared/requirements.txt
echo "See https://github.com/esphome/esphome/releases/ for changes."
