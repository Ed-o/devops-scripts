#!/bin/bash

# Display the users of an AWS account and their secret keys
#
# By Ed ODonnell
# Version : 20260610

# Usage :
#	get-iam-secret-keys.sh			To list the users and their keys
#

# Get AWS ACcount name
account_alias=$(aws iam list-account-aliases --query 'AccountAliases[0]' --output text)

# Get a list of all IAM users
user_list=$(aws iam list-users --query 'Users[*].[UserName]' --output text)

# Iterate through each user
for user in $user_list; do
    aws iam list-access-keys --user-name "$user" --output text | \
        awk -v alias="$account_alias" -v user="$user" 'BEGIN{OFS=","} {print alias,user,$3,$2,$4}'
done

