#!/bin/bash

# Display the users of an AWS account and list the rights for them
#
# By Ed ODonnell
# Version : 20240227

# Usage :
#	get-iam-user-rights.sh			To list the users and their rights
#	get-iam-user-rights.sh -direct		Same but only list direct attach ones, not group ones


# Get a list of all IAM users
user_list=$(aws iam list-users --query 'Users[*].[UserName]' --output text)

# Iterate through each user
for user in $user_list; do
    echo "User: $user"
    
    # Get the policies directly attached to the user
    user_policies=$(aws iam list-attached-user-policies --user-name $user --query 'AttachedPolicies[*].[PolicyName]' --output text)
    
    # Display policies attached directly to the user
    if [ -n "$user_policies" ]; then
        echo "  Directly Attached Policies:"
        echo "$user_policies"
    else
        echo "  No policies directly attached."
    fi
    
    if [ "$1" != "-direct" ] ; then
	    # Get the groups the user belongs to
	    user_groups=$(aws iam list-groups-for-user --user-name $user --query 'Groups[*].[GroupName]' --output text)
	    
	    # Iterate through each group to get policies attached to the group
	    for group in $user_groups; do
	        echo "  Group: $group"
	        
	        # Get policies attached to the group
	        group_policies=$(aws iam list-attached-group-policies --group-name $group --query 'AttachedPolicies[*].[PolicyName]' --output text)
	        
	        # Display policies attached to the group
	        if [ -n "$group_policies" ]; then
	            echo "    Policies Attached via Group:"
	            echo "$group_policies"
	        else
	            echo "    No policies attached via group."
	        fi
	    done
    fi    
    echo "---------------------"
done

