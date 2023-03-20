/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
/***********************
*** Shared Variables ***
************************/
project_id   = "<PROJECT_ID>"



/*************************
*** Region 1 Variables ***
**************************/
region_r1        = "us-central1"
network_name_r1  = "webapp-r1"  # prefix vpc
subnet_name_r1   = "webapp-r1"  # prefix subnet
subnet_ip_r1     = "10.0.16.0/24"
subnet_region_r1 = "us-central1"


/*************************
*** Region 2 Variables ***
**************************/

region_r2        = "us-central1"
network_name_r2  = "webapp-r2"  # prefix vpc
subnet_name_r2   = "webapp-r2"  # prefix subnet
subnet_ip_r2     = "10.0.32.0/24"
subnet_region_r2 = "us-central1"