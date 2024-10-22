#!/bin/bash

# Display the AWS IAM user groups and list the rights for them
#
# By Ed ODonnell
# Version : 20240227

# Usage :
#	get-iam-group-rights.sh			To list the groups and their rights

# Get a list of all IAM groups
group_list=$(aws iam list-groups --query 'Groups[*].[GroupName]' --output text)

# Iterate through each group
for group in $group_list; do
    echo "Group: $group"
    
    # Get policies attached to the group
    group_policies=$(aws iam list-attached-group-policies --group-name $group --query 'AttachedPolicies[*].[PolicyName]' --output text)
    
    # Display policies attached to the group
    if [ -n "$group_policies" ]; then
        echo "  Policies Attached to Group:"
        echo "$group_policies"
    else
        echo "  No policies attached to this group."
    fi
    
    echo "---------------------"
done

