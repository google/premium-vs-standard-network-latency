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
if [[ $# -ne 1 ]]; then
  echo "Usage: create/delete flag"
  exit 1
fi

#Refer to the documentation for full list of possible firewall-rules command arguments - https://cloud.google.com/vpc/docs/using-firewalls#example_1_deny_all_ingress_tcp_connections_except_those_to_port_80_from_subnet1
if [[ $(gcloud compute firewall-rules list --format=json | jq '.[] | .name' | grep ^\"$FWRULENAME | wc -l) -eq 0 ]] && [[ "$1" = "true" ]];then
  gcloud compute --project=$PROJECT_ID firewall-rules create $FWRULENAME --direction=INGRESS --priority=$PRIORITY --network=$NETWORK --action=ALLOW --rules $RULES --source-ranges=`dig TXT o-o.myaddr.l.google.com -4 +short @ns1.google.com | sed 's/"//g'` --target-tags $TARGETTAGS
elif [[ "$1" = "true" ]];then
  gcloud compute --project=$PROJECT_ID firewall-rules update $FWRULENAME --rules $RULES --source-ranges=`dig TXT o-o.myaddr.l.google.com -4 +short @ns1.google.com | sed 's/"//g'`
elif [[ $(gcloud compute firewall-rules list --format=json | jq '.[] | .name' | grep ^\"$FWRULENAME | wc -l) -ne 0 ]];then
  gcloud compute --project=$PROJECT_ID firewall-rules delete $FWRULENAME --quiet
fi