#!/bin/bash

# Check the S3 access rights for all the S3 buckets in the AWS Account
# By Ed ODonnell
# Version 2024-07-12
#
#


# Get the AWS account number
account_id=$(aws sts get-caller-identity --query "Account" --output text)

# Get the AWS account alias
account_alias=$(aws iam list-account-aliases --query "AccountAliases[0]" --output text)

echo "AWS Account ID: $account_id"
echo "AWS Account Alias: $account_alias"


# Fetch the list of all S3 buckets
buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

# Loop through the buckets
for bucket in $buckets; do
    echo "Checking bucket: $bucket"

    # Get the bucket ACL
    acl=$(aws s3api get-bucket-acl --bucket $bucket)

    # Check if the bucket ACL has any grants with a public permission
    if echo "$acl" | grep -q '"Grantee": {"Type": "Group", "URI": "http://acs.amazonaws.com/groups/global/AllUsers"}'; then
        echo "Public access detected in bucket: $bucket"
        # Check if 'Deny public browsing' is enforced (Look for 'BlockPublicAcls' and 'IgnorePublicAcls' in bucket policy)
        public_block_status=$(aws s3api get-bucket-policy-status --bucket $bucket --query "PolicyStatus.BlockPublicAcls" --output text)
        if [ "$public_block_status" == "true" ]; then
            echo "Deny public browsing is enabled for bucket: $bucket"
        else
            echo "*** WARNING *** - Deny public browsing is NOT enabled for bucket: $bucket"
        fi
    #else
        # echo "No public access detected in bucket: $bucket"

    fi
done


