#!/bin/bash

# Setup S3 buckets by turning on versioning and MFA-Delete option 
# Note - this needs to have the root MFA key listed below and a current passcode put in as $1 parameter

# By Ed ODonnell
# Version : 20240301

mfa_arn="<insert your ARN here>"
mfa_token_code="$1"

# Get a list of S3 buckets from current account 
buckets=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)

# Loop through each bucket, enable versioning if not already enabled, and then enable MFA Delete
for bucket in $buckets; do
    versioning_status=$(aws s3api get-bucket-versioning --bucket $bucket --query 'Status' --output text)
    if [ "$versioning_status" != "Enabled" ]; then
        echo "Enabling versioning for bucket $bucket..."
        aws s3api put-bucket-versioning --bucket $bucket --versioning-configuration Status=Enabled
        if [ $? -eq 0 ]; then
            echo "Versioning enabled for bucket $bucket"
        else
            echo "Failed to enable versioning for bucket $bucket"
            continue
        fi
    else
        echo "Versioning already enabled for bucket $bucket"
    fi

    echo "Enabling MFA Delete for bucket $bucket..."
    aws s3api put-bucket-versioning --bucket $bucket --versioning-configuration Status=Enabled,MFADelete=Enabled --mfa "$mfa_arn" --mfa-token $mfa_token_code
    if [ $? -eq 0 ]; then
        echo "MFA Delete enabled for bucket $bucket"
    else
        echo "Failed to enable MFA Delete for bucket $bucket"
    fi
done
