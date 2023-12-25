#!/bin/bash
# Copyright 2023 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

# Upgrades esphome and its dependencies.

set -eu

cd "$(dirname $0)"
cd ..

source .venv/bin/activate
pip install -U pip
pip install -U esphome
# For fonts support.
pip install -U pillow
pip freeze > esphome-shared/requirements.txt

git diff esphome-shared/requirements.txt
echo "See https://github.com/esphome/esphome/releases/ for changes."
