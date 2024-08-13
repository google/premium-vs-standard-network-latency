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

# Replace with your ISP name. Must be all lowercase as this will also be used for setting firewall rule with constraint - Must be a match of regex '(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?) 
export ISP="paul-whitesky"

# Replace with your project name
export PROJECT_ID="paulsandbox"
