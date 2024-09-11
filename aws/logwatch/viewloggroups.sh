#!/bin/bash

# ViewLogGroups
# Output :
# Log Group Name, Total Size , Retention (Days), Estimated Cost (USD)
#
# Version : 20240911

# Variables 
# DEBUG="TRUE"                     # Just turn this on if you get lost or stuck
price_per_gb_storage=0.03        # AWS Pricing for CloudWatch Logs (per GB). Priced as per 2023 in US-East-1

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
log_groups_list=$(aws logs describe-log-groups --query 'logGroups[*].logGroupName' --output json)

echo "Fetching data for each log group..."
echo "Log Group Name, Total Size , Retention (Days), Estimated Cost (USD)"
echo "==================================================================="

# Loop through each log group
for log_group in $(echo "$log_groups_list" | jq -r ".[]"); do
    if [ "$DEBUG" == "TRUE" ] ; then
      echo "Processing log group: $log_group"
    fi

    # Get log group details (size, retention)
    log_details=$(aws logs describe-log-groups --log-group-name-prefix "$log_group" --query 'logGroups[*].[logGroupName,storedBytes,retentionInDays]' --output=json | jq -r --arg log_group "$log_group" '.[] | select(.[0] == $log_group)')
    
    # Lets see what is inside (debug only)
    if [ "$DEBUG" == "TRUE" ] ; then
      echo "$log_details"
    fi

    # lets break these out of the json blob into strings
    log_name=$(echo "$log_details" | jq -r '.[0]')
    stored_bytes=$(echo "$log_details" | jq -r '.[1]')
    retention_days=$(echo "$log_details" | jq -r '.[2]')
  
    # Format the retention period 
    if [ "$retention_days" == "null" ] ; then
      retention="No Retention"
    else 
      retention="Retain for $retention_days days"
    fi

    # Calculate cost for storage
    total_size_gb=$(echo "scale=3; $stored_bytes / 1073741824" | bc)  # Convert bytes to GB
    estimated_cost=$(echo "scale=2; $total_size_gb * $price_per_gb_storage" | bc)

    echo "$log_name, Size = $stored_bytes ($total_size_gb GB), $retention, $estimated_cost USD"

done

