#!/bin/bash

# Check unused AWS resourses
# (EIPs, EC2, EBS Volumes, LBs, SGs)
# Note this doesn't do everything - it just spots the obvious fails
#
# Version 20241022
#
 

# Get all available AWS regions
regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

# Function to find unused resources in a region
check_unused_resources() {
    region=$1
    echo "Checking region: $region"

    # Unused Elastic IPs (EIPs)
    echo "  Unused Elastic IPs:"
    eips=$(aws ec2 describe-addresses --region "$region" --query 'Addresses[?AssociationId==null].PublicIp' --output text)
    if [ -z "$eips" ]; then
        echo "    No unused Elastic IPs."
    else
        echo "$eips" | while read ip; do
            echo "    Elastic IP: $ip is not associated with any resource."
        done
    fi

    # Unattached EBS Volumes
    echo "  Unattached EBS Volumes:"
    unattached_volumes=$(aws ec2 describe-volumes --region "$region" --query 'Volumes[?State==`available`].[VolumeId,Size]' --output text)
    if [ -z "$unattached_volumes" ]; then
        echo "    No unattached EBS volumes."
    else
        echo "$unattached_volumes" | while read volume_id size; do
            echo "    Volume ID: $volume_id, Size: ${size}GiB is not attached to any instance."
        done
    fi

    # Stopped EC2 Instances
    echo "  Stopped EC2 Instances:"
    stopped_instances=$(aws ec2 describe-instances --region "$region" --filters Name=instance-state-name,Values=stopped --query 'Reservations[*].Instances[*].InstanceId' --output text)
    if [ -z "$stopped_instances" ]; then
        echo "    No stopped EC2 instances."
    else
        echo "$stopped_instances" | while read instance_id; do
            echo "    Instance ID: $instance_id is stopped."
        done
    fi

    # Unused Elastic Load Balancers (ELBv2)
    echo "  Unused Load Balancers:"
    load_balancers=$(aws elbv2 describe-load-balancers --region "$region" --query 'LoadBalancers[*].LoadBalancerArn' --output text)
    if [ -z "$load_balancers" ]; then
        echo "    No load balancers found."
    else
        for lb_arn in $load_balancers; do
            target_health=$(aws elbv2 describe-target-health --load-balancer-arn "$lb_arn" --region "$region" --query 'TargetHealthDescriptions' --output text)
            if [ -z "$target_health" ]; then
                lb_name=$(aws elbv2 describe-load-balancers --load-balancer-arns "$lb_arn" --region "$region" --query 'LoadBalancers[*].LoadBalancerName' --output text)
                echo "    Load Balancer: $lb_name has no targets."
            fi
        done
    fi

    # Unused Security Groups
    echo "  Unused Security Groups:"
    security_groups=$(aws ec2 describe-security-groups --region "$region" --query 'SecurityGroups[?length(IpPermissions)==`0` && length(IpPermissionsEgress)==`0`].[GroupId,GroupName]' --output text)
    if [ -z "$security_groups" ]; then
        echo "    No unused security groups found."
    else
        echo "$security_groups" | while read group_id group_name; do
            echo "    Security Group: $group_name (ID: $group_id) has no inbound or outbound rules."
        done
    fi

    echo ""
}

# Loop through each region and check for unused resources
for region in $regions; do
    check_unused_resources "$region"
done

