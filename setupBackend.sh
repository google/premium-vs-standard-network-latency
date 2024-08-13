#!/bin/bash
# 
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Check if a filename was provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <filename.csv> create/delete flag"
  exit 1
fi

# Delete backend.csv from previous run
if [[ -f "backend.csv" ]]; then
  rm $CWD/backend.csv
fi
touch $CWD/backend.csv

# Check if a filename was provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <filename.csv>"
  exit 1
fi

# Add the header row
echo "NetworkTier,RegionZone,IP" > $CWD/backend.csv

# Read the CSV file line by line
while IFS= read -r RegionZone || [[ -n "$RegionZone" ]]; do # Or condition is added to read the last line in case the file does not end with a newline character
    # check if there are exactly three columns
    if [[ -n "$RegionZone" ]]; then
        if [[ "$2" = "true" ]]; then
            . $CWD/createBackend.sh $RegionZone true
        else
            . $CWD/createBackend.sh $RegionZone false
        fi
    fi
done < <(tail -n +2 "$1")