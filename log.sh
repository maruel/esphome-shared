#!/bin/bash
# Copyright 2023 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

# Capture log output from a device using log_debug.yaml

set -eu

cd "$(dirname $0)"
cd ..
if [ ! -f .venv/bin/activate ]; then
  echo "run setup.sh"
  exit 1
fi

source .venv/bin/activate
esphome logs "$@"
