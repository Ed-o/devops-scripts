#!/bin/bash

# A script to add a collection of DNS records into R53 in AWS using the AWS CLI tool
# 
# By Ed ODonnell
# Version : 20240502
#
#


zoneid=Z01234567890123456
domain="example-company.com"

# Array of hosts and values
records=(
"A Record:demo:10.20.30.40"
"CNAME Record:test-rec:abc123.cloudfront.net."
)

# Loop through each record and add it to Route 53
for record in "${records[@]}"; do
	thetype=$(echo "$record" | cut -d: -f1)
	host=$(echo "$record" | cut -d: -f2)
	value=$(echo "$record" | cut -d: -f3)
    
	type=""   
	if [ "$thetype" == "A Record" ] ; then type="A"; fi
	if [ "$thetype" == "CNAME Record" ] ; then type="CNAME"; fi
	if [ "$thetype" == "TXT Record" ] ; then type="TXT"; fi
	echo "Adding record: $host [$type] -> $value"

	aws route53 change-resource-record-sets \
	  --hosted-zone-id $zoneid \
	  --change-batch '
	{
	  "Comment": "",
	  "Changes": [{
		"Action"              : "CREATE",
		"ResourceRecordSet"  : {
			"Name"              : "'"$host.$domain"'",
			"Type"             : "'"$type"'",
		        "TTL"              : 120,
			"ResourceRecords"  : [{
				"Value"         : "'"$value"'"
			}]
		}
	  }]
	}'
done


