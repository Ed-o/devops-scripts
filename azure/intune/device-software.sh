#!/bin/bash

# Bash Script to output a list of software linked to each machine in your inTune collection
#
# By Ed ODonnell
# Ver : 2024-09-27 

# Required variables
TENANT_ID="tenant-id-goes-here"
CLIENT_ID="client-id-goes-here"
CLIENT_SECRET="client-secret-goes-here"  
RESOURCE="https://graph.microsoft.com"
API_VERSION="v1.0"
OUT_FILE="intune_device_software.csv"



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
APPS=$(curl -s -X GET -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "https://graph.microsoft.com/$API_VERSION/deviceManagement/detectedApps?$expand=managedDevices" | jq -r '.value[] | {id, displayName, version} ')

# go through each device and see if it matches
echo "$APPS" | jq -c '.[]' | while read -r TEMP_APP_ID; do
    APP_ID=`echo "$TEMP_APP_ID" | tr -d '"'`
    read -r APP_NAME
    read -r APP_VERSION

    echo "Testing App : $APP_ID ==> $APP_NAME"
    DEVLIST=$(curl -s -X GET -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        "https://graph.microsoft.com/beta/deviceManagement/detectedApps/$APP_ID/managedDevices?select=id,deviceName,emailAddress" | jq -r '.value[] | {deviceName, emailAddress} ')

    echo "$DEVLIST" | jq -c '.[]' | while read -r DEVICE_NAME; do
        read -r DEVICE_EMAIL
        echo "$DEVICE_NAME, $DEVICE_EMAIL, $APP_NAME, $APP_VERSION" >> $OUT_FILE
    done
done

echo "Data written to $OUT_FILE"



