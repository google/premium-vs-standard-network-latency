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

# Delete crontab.txt from previous run
if [[ -f "crontab.txt" ]]; then
  rm $CWD/crontab.txt
fi
touch $CWD/crontab.txt

# Check if a filename was provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <filename.csv> create/delete flag"
  exit 1
fi

# Backup the current crontab and delete the previously scheduled latency scripts
crontab -l > crontab_backup.txt
sed "/SHELL/d" crontab_backup.txt > crontab_backup.txt
sed "/BASH_ENV/d" crontab_backup.txt > crontab_backup.txt
sed "/$ISP-$NetworkTier-network_latency-$RegionZone/d" crontab_backup.txt > crontab_backup.txt

if [[ "$2" = "true" ]]; then
  # Add the shell directives for the Cron to execute the script
  echo "SHELL=/bin/bash" > $CWD/crontab.txt
  echo "BASH_ENV=~/.bashrc" >> $CWD/crontab.txt
  cat crontab_backup.txt >> $CWD/crontab.txt

  # Read the CSV file line by line
  while IFS=, read -r NetworkTier RegionZone IP || [[ -n "$NetworkTier" ]]; do # Or condition is added to read the last line in case the file does not end with a newline character
      # check if there are exactly three columns
      if [[ -n "$NetworkTier" ]] && [[ -n "$RegionZone" ]] && [[ -n "$IP" ]]; then
        echo "* * * * * ${CWD}/postNetworkLatencyMetrics.sh -p '$PROJECT_ID' -t '$IP' -m '$ISP-$NetworkTier-network_latency-$RegionZone' >> /tmp/$ISP-$NetworkTier-network_latency-$RegionZone.log 2>&1" >> $CWD/crontab.txt
      fi
  done < <(tail -n +2 "$1")
else
  crontab -l > crontab.txt
  sed "/$ISP-$NetworkTier-network_latency-$RegionZone/d" crontab.txt > crontab.txt
fi