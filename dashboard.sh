#!/bin/bash
# Copyright 2023 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

# Runs the esphome dashboard.

set -eu

cd "$(dirname $0)"
cd ..

source .venv/bin/activate
esphome dashboard .
