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

while getopts p:t:m: flag
do
    case "${flag}" in
        p) PROJECT_ID=${OPTARG};;
        t) TARGET_HOST=${OPTARG};;
        m) METRIC_NAME=${OPTARG};;
    esac
done

# Configuration
API_ENDPOINT="https://monitoring.googleapis.com/v3/projects/$PROJECT_ID/timeSeries"
ACCESS_TOKEN=$(gcloud auth application-default print-access-token) # Get token from gcloud
PING_COUNT=10
UNAME=$(uname)

# Get ping latency statistics (mean)
if [[ "$UNAME" = "Darwin" ]]; then
  latency_ms=$(/sbin/ping -c $PING_COUNT $TARGET_HOST | awk -F '/' '/round-trip/ { print $5 }')
else
  latency_ms=$(ping -c $PING_COUNT $TARGET_HOST | awk -F '/' '/rtt/ { print $5 }')
fi


# Timestamp (required for GCP custom metrics)
timestamp=$(date +%s)

# Construct JSON payload for the metric entry
metric_json=$(cat <<EOF
{
  "timeSeries": [
    {
      "metric": {
        "type": "custom.googleapis.com/$METRIC_NAME"
      },
      "resource": {
        "type": "global"
      },
      "points": [
        {
          "interval": {
            "startTime": {
              "seconds": $timestamp
            },
            "endTime": {
              "seconds": $timestamp
            }
          },
          "value": {
            "doubleValue": $latency_ms
          }
        }
      ]
    }
  ]
}
EOF
)

# Send the Request
RESPONSE=$(curl -X POST "$API_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d "$metric_json")

echo "Project ID: $PROJECT_ID";
echo "Target Host: $TARGET_HOST";
echo "Latency ms: $latency_ms";
echo "Metric.json: ";
echo "$metric_json";
echo "Response: $RESPONSE";

# Error Handling
if [[ $(echo "$RESPONSE" | jq ".error") != null ]]; then
  echo "Error uploading metric: $(echo "$RESPONSE" | jq '.error')"
else
  echo "Metric uploaded successfully!"
fi