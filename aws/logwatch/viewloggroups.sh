#!/bin/bash

# ViewLogGroups
# Output :
# Log Group Name, Total Size (Bytes), Retention (Days), Expiry Date (if available), Estimated Cost (USD)
#
# Version : 20240911

# Check if AWS CLI is installed
if ! [ -x "$(command -v aws)" ]; then
  echo 'Error: AWS CLI is not installed.' >&2
  exit 1
fi

# Function to convert timestamp to human-readable date
convert_timestamp() {
  local timestamp=$1
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    date -d "@$timestamp" '+%Y-%m-%d'
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    date -r "$timestamp" '+%Y-%m-%d'
  else
    echo "Unsupported OS"
    exit 1
  fi
}

# Get all CloudWatch log groups
log_groups=$(aws logs describe-log-groups --query 'logGroups[*].logGroupName' --output text)

echo "Fetching data for each log group..."
echo "Log Group Name, Total Size (Bytes), Retention (Days), Expiry Date (if available), Estimated Cost (USD)"

# AWS Pricing for CloudWatch Logs (per GB)
# Note: $0.03 per GB for ingestion, $0.03 per GB for storage.
# Pricing as of 2023. You may need to adjust this for your region.
price_per_gb_storage=0.03

# Loop through each log group
for log_group in $log_groups; do
  echo "Processing log group: $log_group"

  # Get log group details (size, retention)
  log_streams=$(aws logs describe-log-streams --log-group-name "$log_group" --query 'logStreams[*].[logStreamName,storedBytes,lastIngestionTime]' --output text)
  
  total_size=0
  expiry_date="N/A"

  while read -r stream_name stored_bytes last_ingestion_time; do
    total_size=$((total_size + stored_bytes))
    
    # Calculate expiry date if retention policy is set
    retention=$(aws logs describe-log-groups --log-group-name-pattern "$log_group" --query 'logGroups[*].retentionInDays' --output text)

    if [ "$retention" == "" ]; then 
        retention="None"
    fi

    if [ "$retention" != "None" ]; then
      last_ingestion_sec=$((last_ingestion_time / 1000))
      expiry_timestamp=$((last_ingestion_sec + retention * 86400))
      expiry_date=$(convert_timestamp "$expiry_timestamp")
    fi

  done <<< "$log_streams"

  # Calculate cost for storage
  total_size_gb=$(echo "scale=3; $total_size / 1073741824" | bc)  # Convert bytes to GB
  estimated_cost=$(echo "scale=2; $total_size_gb * $price_per_gb_storage" | bc)

  echo "$log_group, $total_size Bytes, $retention Days, $expiry_date, $estimated_cost USD"

done

