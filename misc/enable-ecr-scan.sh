#!/bin/bash

# Set the ECR repostiroies in AWS to have scan enabled
# By Ed ODonnell
#
# Version : 20240223

if [ $# -eq 0 ] ; then
        echo "What region do you want to update ?"
	echo "usage :    enable-ecr-scan.sh eu-west-1"
	echo " "
        exit 0
else
	REGION="$1"
	REPOS=$(aws ecr describe-repositories --query "repositories[].repositoryName" --output text --region $REGION);
	for repo in $REPOS; do
		echo "----- > Updating scan preferences for : $repo"
		result1=`aws ecr describe-repositories --region $REGION --repository-names $repo --query "repositories[*].imageScanningConfiguration.scanOnPush" --output text`
		echo "It is currently set to : $result1"
		if [ "$result1" != "True" ] ; then
			result2=`aws ecr put-image-scanning-configuration --region $REGION --repository-name $repo --image-scanning-configuration scanOnPush=true`
			result3=`aws ecr describe-repositories --region $REGION --repository-names $repo --query "repositories[*].imageScanningConfiguration.scanOnPush" --output text`
	                echo "It is now set to : $result3"
		else
			echo "So no need to change anything"
		fi
	done
fi
