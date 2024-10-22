#!/bin/bash

# Show elastic IPs in current AWS account
#
# By Ed ODonnell
# Version : 20241022

# Get all available AWS regions
regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

# Loop through each region
for region in $regions; do
    echo "Region: $region"
    
    # Get all Elastic IPs in the region
    elastic_ips=$(aws ec2 describe-addresses --region "$region" --query 'Addresses[*].{PublicIp:PublicIp,InstanceId:InstanceId,NetworkInterfaceId:NetworkInterfaceId,AssociationId:AssociationId}' --output json)

    # Check if there are any Elastic IPs
    if [ "$elastic_ips" == "[]" ]; then
        echo "  No Elastic IPs found."
    else
        # Parse and display Elastic IP information
        echo "$elastic_ips" | jq -c '.[]' | while read ip_info; do
            public_ip=$(echo "$ip_info" | jq -r '.PublicIp')
            instance_id=$(echo "$ip_info" | jq -r '.InstanceId')
            network_interface_id=$(echo "$ip_info" | jq -r '.NetworkInterfaceId')
            association_id=$(echo "$ip_info" | jq -r '.AssociationId')

            echo "  Elastic IP: $public_ip"

            if [ "$instance_id" != "null" ]; then
                echo "    Associated with Instance: $instance_id"
            elif [ "$network_interface_id" != "null" ]; then
                echo "    Associated with Network Interface: $network_interface_id"
            elif [ "$association_id" != "null" ]; then
                echo "    Association ID: $association_id"
            else
                echo "    Not associated with any resource"
            fi
        done
    fi
    echo ""
done

