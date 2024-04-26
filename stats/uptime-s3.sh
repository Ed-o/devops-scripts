# Get a list of all S3 buckets
buckets=$(aws s3api list-buckets --query 'Buckets[].Name' --output text)

# Calculate the start time
start_time=$(date -u -v -1d '+%Y-%m-%dT%H:%M:%SZ')

# Get the AllRequests metric for each bucket
for bucket in $buckets; do
    result=$(aws cloudwatch get-metric-statistics \
        --namespace "AWS/S3" \
        --metric-name "AllRequests" \
        --start-time "$start_time" \
        --end-time "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
        --period 3600 \
        --statistics "Sum" \
        --dimensions Name="BucketName",Value="$bucket" )
        # --query "sum(Sum)")

    if [ -z "$result" ]; then
        echo "No data available for S3 bucket: $bucket"
    else
        echo "$result"
    fi
done
