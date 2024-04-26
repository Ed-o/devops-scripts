#!/bin/bash

# List S3 Buckets that have web access enbabled 

# By Ed ODonnell
# Version : 20240301

# Get a list of S3 buckets from current account 
buckets=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)

# Loop through each bucket
for bucket in $buckets; do
    echo "Bucket: $bucket"

    # Get bucket website configuration
    website_config=$(aws s3api get-bucket-website --bucket $bucket 2>/dev/null)

    # Check if bucket is configured as a static website
    if [[ ! -z "$website_config" ]]; then
        echo "  - Configured as a static website"

        # Check if HTTP access is enabled
        http_endpoint=$(echo $website_config | jq -r 'select(.EndpointConfiguration != null) | .EndpointConfiguration.WebsiteEndpoint')
        if [[ ! -z "$http_endpoint" ]]; then
            echo "    - HTTP access enabled: $http_endpoint"
        else
            echo "    - HTTP access not enabled"
        fi

        # Check if HTTPS access is enabled
        https_endpoint=$(echo $website_config | jq -r 'select(.EndpointConfiguration != null) | .EndpointConfiguration.WebsiteEndpoint')
        if [[ ! -z "$https_endpoint" ]]; then
            echo "    - HTTPS access enabled: $https_endpoint"
        else
            echo "    - HTTPS access not enabled"
        fi
    else
        echo "  - Not configured as a static website"
    fi
done
