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

# Read the CSV file line by line
while IFS=, read -r RegionZone || [[ -n "$RegionZone" ]]; do # Or condition is added to read the last line in case the file does not end with a newline character
    # check if there are exactly three columns
    if [[ -n "$RegionZone" ]]; then
        METRIC_NAME="${ISP}-p-network_latency-${RegionZone//\'/}"
        . $CWD/deleteMetric.sh -p "${PROJECT_ID}" -m "${METRIC_NAME}"
        METRIC_NAME="${ISP}-s-network_latency-${RegionZone//\'/}"
        . $CWD/deleteMetric.sh -p "${PROJECT_ID}" -m "${METRIC_NAME}"
    fi
done < <(tail -n +2 "$1")