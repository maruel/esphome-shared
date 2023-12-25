#!/bin/bash
# Copyright 2023 Marc-Antoine Ruel. All rights reserved.
# Use of this source code is governed under the Apache License, Version 2.0
# that can be found in the LICENSE file.

# Flash all the firmwares except the unused devices. It's a good idea to run
# compile_all.sh first.

set -eu

cd "$(dirname $0)"
cd ..

source .venv/bin/activate

echo "If one fails, either rename the file to _unused.yaml or edit devs.txt and"
echo "run again this command again."
echo ""

if [ ! -f devs.txt ]; then
  ls *.yaml | grep -v unused | grep -v 'secrets\.yaml' > devs.txt
fi

for i in $(cat devs.txt); do
  echo $i
  esphome --quiet run --no-logs $i
done

# Success
rm devs.txt
