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

while getopts p:m: flag
do
    case "${flag}" in
        p) PROJECT_ID=${OPTARG};;
        m) METRIC_NAME=${OPTARG};;
    esac
done

# Configuration
API_ENDPOINT="https://monitoring.googleapis.com/v3/projects/$PROJECT_ID/metricDescriptors"
ACCESS_TOKEN=$(gcloud auth application-default print-access-token) # Get token from gcloud

echo "Metric Name: $METRIC_NAME";

# Send the Request
RESPONSE=$(curl -X DELETE "$API_ENDPOINT/custom.googleapis.com/$METRIC_NAME" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d "")

# Error Handling
if [[ $(echo "$RESPONSE" | jq ".error") != null ]]; then
  echo "Error deleting metric: $(echo "$RESPONSE" | jq '.error')"
else
  echo "Metric deleted successfully!"
fi