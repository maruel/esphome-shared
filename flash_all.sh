#!/bin/bash
# Copyright 2023 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

# Flash all the firmwares except the unused devices. It's a good idea to run
# compile_all.sh first.

set -eu

cd "$(dirname $0)"
cd ..
if [ ! -f .venv/bin/activate ]; then
  echo "run setup.sh"
  exit 1
fi

source .venv/bin/activate

echo "If one fails, either rename the file to test*.yaml or edit devs.txt and"
echo "run again this command again."
echo ""

if [ ! -f devs.txt ]; then
  ls *.yaml | grep -v 'secrets\.yaml' > devs.txt
fi

for i in $(cat devs.txt); do
  if [[ $i == *.unused.yaml ]]; then
    echo "- Compiling: $i"
    esphome compile $i
  else
    echo "- Updating: $i"
    esphome --quiet run --no-logs $i
  fi
done

# Success
rm devs.txt
