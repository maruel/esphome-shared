#!/bin/bash
# Copyright 2023 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

# Compile all the firmwares to ensure they are okay with the new esphome
# version.

set -eu

cd "$(dirname $0)"
cd ..
if [ ! -f .venv/bin/activate ]; then
  echo "run setup.sh"
  exit 1
fi

source .venv/bin/activate

echo "If one fails, either fix the file or edit devs.txt and"
echo "run again this command again."
echo ""

if [ ! -f devs.txt ]; then
  ls *.yaml | grep -v 'secrets\.yaml' > devs.txt
fi

for i in $(cat devs.txt); do
  echo $i
  esphome --quiet compile $i
done

# Success
rm devs.txt
