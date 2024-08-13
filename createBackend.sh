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

# Ensure required arguments are provided
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <zone>, create/delete flag"
  exit 1
fi

# Variables from arguments
ZONE="$1"
CREATE="$2"
INSTANCE_PREFIX="latencytest"

# Function to check for existing instances
function check_existing_instances() {
  existing_instances=$(gcloud compute instances list --filter="name~^$1 AND zone:($ZONE)" --format="value(name)")
  if [[ -n "$existing_instances" ]]; then
    return 0
  else
    return 1
  fi
}

# Function to create a new instance
function create_instance() {
  
  echo "Creating instance: $INSTANCE_NAME $1"

  gcloud compute instances create $INSTANCE_NAME \
    --zone=$1 \
    --machine-type=e2-micro   \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --network-interface=network-tier=$2,stack-type=IPV4_ONLY \
    --maintenance-policy=MIGRATE \
    --metadata=enable-oslogin=true \
    --shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --tags=$TARGETTAGS
}

# Main script logic
# echo "Checking for existing instances in $ZONE starting with $INSTANCE_PREFIX..."
INSTANCE_NAME="${INSTANCE_PREFIX}-p-${ZONE}"  # Unique name based on zone and network tier
check_existing_instances $INSTANCE_NAME
if [[ $? -eq 1 ]] && [[ "$CREATE" = "true" ]]; then  # Check the exit code of the function
  create_instance $ZONE PREMIUM
fi
check_existing_instances $INSTANCE_NAME
if [[ $? -eq 0 ]] && [[ "$CREATE" = "false" ]]; then # Delete the GCE instance
  gcloud compute instances delete $INSTANCE_NAME --zone $ZONE --quiet
fi
if [[ "$CREATE" = "true" ]]; then
  echo "p,'${ZONE}',`gcloud compute instances describe ${INSTANCE_NAME} --format='get(networkInterfaces[0].accessConfigs[0].natIP)' --zone ${ZONE}`" >> $CWD/backend.csv
fi
INSTANCE_NAME="${INSTANCE_PREFIX}-s-${ZONE}" 
check_existing_instances $INSTANCE_NAME
if [[ $? -eq 1 ]] && [[ "$CREATE" = "true" ]]; then   # Check the exit code of the function
  create_instance $ZONE STANDARD
fi
check_existing_instances $INSTANCE_NAME
if [[ $? -eq 0 ]] && [[ "$CREATE" = "false" ]]; then # Delete the GCE instance
  gcloud compute instances delete $INSTANCE_NAME  --zone $ZONE --quiet
fi
if [[ "$CREATE" = "true" ]]; then
  echo "s,'${ZONE}',`gcloud compute instances describe ${INSTANCE_NAME} --format='get(networkInterfaces[0].accessConfigs[0].natIP)' --zone ${ZONE}`" >> $CWD/backend.csv
fi