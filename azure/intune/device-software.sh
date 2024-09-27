#!/bin/bash

# Bash Script to output a list of software linked to each machine in your inTune collection
#
# By Ed ODonnell
# Ver : 2024-09-27 

# Required variables
TENANT_ID="tenant-id-goes-here"
CLIENT_ID="client-id-goes-here"
CLIENT_SECRET="client-secret-goes-here"  
ONLY_LOOK_AT_SW=""      # Just look at this software name
RESOURCE="https://graph.microsoft.com"
API_VERSION="v1.0"
OUT_FILE="intune_device_software.csv"
RETRY_LIMIT=5
SLEEP_TIME=10

# Function to make curl requests with retry logic in case MS API tells us off for too many requests
make_request() {
    local url=$1
    local token=$2
    local retries=0
    local response=""

    # Retry loop
    while [ $retries -lt $RETRY_LIMIT ]; do
        response=$(curl -s -X GET -H "Authorization: Bearer $token" \
            -H "Content-Type: application/json" "$url")

        # Check for rate limiting or errors
        if [[ $(echo "$response" | jq -r '.error.code') == "TooManyRequests" ]] || [ "$response" == "" ]; then
            # echo "Rate limit hit. Retrying in $SLEEP_TIME seconds..."
            sleep $SLEEP_TIME
            retries=$((retries + 1))
        else
            break
        fi
    done

    if [ $retries -eq $RETRY_LIMIT ]; then
        echo "Failed to get a successful response after $RETRY_LIMIT retries."
        exit 1
    fi

    echo "$response"
}


# Get an OAuth2 token
TOKEN=$(curl -s -X POST -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=client_credentials&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&scope=$RESOURCE/.default" \
    https://login.microsoftonline.com/$TENANT_ID/oauth2/v2.0/token | jq -r .access_token)

# Check if token was retrieved
if [ -z "$TOKEN" ]; then
    echo "Failed to get an access token."
    exit 1
fi

# Write CSV header
echo "Workstation, Email(of owner), Software Name, Version" > $OUT_FILE

# Get the list of detected applications across all devices
APPS_URL="https://graph.microsoft.com/$API_VERSION/deviceManagement/detectedApps?$expand=managedDevices" 
APPS=$(make_request "$APPS_URL" "$TOKEN" | jq -r '.value[] | {id, displayName, version} ')

# Split out the app data and then go through each device and see if it matches
echo "$APPS" | jq -c '.[]' | while read -r TEMP_APP_ID; do
    APP_ID=`echo "$TEMP_APP_ID" | tr -d '"'`
    read -r APP_NAME
    read -r APP_VERSION

    if [ "$ONLY_LOOK_AT_SW" == "" -o "\"$ONLY_LOOK_AT_SW\"" == "$APP_NAME" ]; then 
        echo "Testing App : $APP_ID ==> $APP_NAME"
        DEV_URL="https://graph.microsoft.com/beta/deviceManagement/detectedApps/$APP_ID/managedDevices?select=id,deviceName,emailAddress" 
        TEMPDEVLIST=$(make_request "$DEV_URL" "$TOKEN")
	DEVLIST=$(echo "$TEMPDEVLIST" | jq -r '.value[] | {deviceName, emailAddress} ')
	# echo "$TEMPDEVLIST"

        echo "$DEVLIST" | jq -c '.[]' | while read -r DEVICE_NAME; do
            read -r DEVICE_EMAIL
            echo "$DEVICE_NAME, $DEVICE_EMAIL, $APP_NAME, $APP_VERSION" >> $OUT_FILE
        done
    else
        echo "Skipping : $APP_NAME"
    fi
done

echo "Data written to $OUT_FILE"



