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

# Get the current working directory
CWD=$(pwd)
$(chmod ugo+x $CWD/prereq.sh)

#Set Env variables
. $CWD/prereq.sh

if ! [[ -f ~/.bashrc ]]; then
  touch ~/.bashrc &&
  echo 'export PATH="'$PATH'"' >> ~/.bashrc
fi
if ! [[ $(grep 'PROJECT_ID' ~/.bashrc) ]]; then
  echo 'export PROJECT_ID="'$PROJECT_ID'"' >> ~/.bashrc
fi


# Set executable permission on scripts
$(chmod ugo+x $CWD/postNetworkLatencyMetrics.sh)
$(chmod ugo+x $CWD/firewall.sh)
$(chmod ugo+x $CWD/setupBackend.sh)
$(chmod ugo+x $CWD/deleteMetrics.sh)
$(chmod ugo+x $CWD/deleteMetric.sh)

# Modify the ENV variables below to customize firewall rule creation
FWRULENAME='latencytest'-${ISP}
PRIORITY='1000'
RULES='icmp'
TARGETTAGS='latencytest'
NETWORK='default'

# delete firewall rule
. $CWD/firewall.sh false

# delete backend instances
. $CWD/setupBackend.sh backendRegion.csv false

# Write crontab.txt file
. $CWD/crontab.sh backend.csv false

echo "$CWD/crontab.txt"
# Add crontab schedule
crontab $CWD/crontab.txt