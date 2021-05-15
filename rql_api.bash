#!/bin/bash
# Written By Kyle Butler
# Tested on 5.4.2021 on prisma_cloud_enterprise_edition using Ubuntu 20.04

# Requires jq to be installed sudo apt-get install jq


# Access key should be created in the Prisma Cloud Console under: Settings > Accesskeys
# I'm making a conscious decision to leave access keys in the script to simplify the workflow
# My recommendations for hardening is to store these variables in a secret manager of choice or
# export the access keys/secret key as env variables in a separate script. 
# Place the access key and secret key between "<ACCESS_KEY>", <SECRET_KEY> marks respectively below.


# Only variable(s) needing to be assigned by the end-user
# Found on https://prisma.pan.dev/api/cloud/api-urls, replace value below

pcee_console_api_url="api.prismacloud.io"

# Create access keys in the Prisma Cloud Enterprise Edition Console

pcee_accesskey="<ACCESS_KEY>"
pcee_secretkey="<SECRET_KEY>"

# This is where the tags, and scan information live. Recommending putting this script in the same directory as the this file so you don't need to alter the location below. 

pcee_payload_file_location="./config-file-template.json"


# This is found  in the Prisma Cloud Console under: Compute > Manage/System on the downloads tab under Path to Console
pcee_console_url="<REPLACE_WITH_THE_APPROPRIATE_VALUE_FOUND__IN_COMMENT_ABOVE>"


# NOTHING BELOW THIS LINE NEEDS TO BE ALTERED
# not used in this script
pcee_api_limit=50

# so the json "config" file can be read by the curl command properly. 
pcee_payload_file=$(cat "${pcee_payload_file_location}")

# This variable formats everything correctly so that the next variable can be assigned.
pcee_auth_body="{\"username\":\""${pcee_accesskey}"\", \"password\":\""${pcee_secretkey}"\"}"

# This saves the auth token needed to access the CSPM side of the Prisma Cloud API to a variable I named $pcee_auth_token
pcee_auth_token=$(curl -s --request POST \
--url https://"${pcee_console_api_url}"/login \
--header 'Accept: application/json; charset=UTF-8' \
--header 'Content-Type: application/json; charset=UTF-8' \
--data "${pcee_auth_body}" | jq -r '.token')

# This variable formats everything correctly so that the next variable can be assigned.
pcee_compute_auth_body="{\"username\":\""${pcee_accesskey}"\", \"password\":\""${pcee_secretkey}"\"}"

# This saves the auth token needed to access the CWPP side of the Prisma Cloud API to a variable $pcee_compute_token
pcee_compute_token=$(curl -s \
-H "Content-Type: application/json" \
-d "${pcee_compute_auth_body}" \
"${pcee_console_url}"/api/v1/authenticate | jq -r '.token')


curl -s --request POST \
--url https://"${pcee_console_api_url}"/search/config \
--header 'content-type: application/json; charset=UTF-8' \
--header "x-redlock-auth: "${pcee_auth_token}"" \
--header "Accept: text/csv" \
--data "${pcee_payload_file}"
