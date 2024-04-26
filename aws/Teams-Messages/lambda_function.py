import urllib3
import json
import boto3

http = urllib3.PoolManager()

def lambda_handler(event, context):
    for record in event['Records']:
        print(record)
        process_message(record)
    print("done")

def process_message(record):
    try:
        subject = record['Sns']['Subject']
        message = record['Sns']['Message']
        messageItems = json.loads(message)
        accountID = messageItems['AWSAccountId']
        alarmDescription = messageItems.get('AlarmDescription', 'No description provided')
        newStateReason = messageItems['NewStateReason']
        
        body =  f"Account : {accountID}<br />\n" \
                f"Description : {alarmDescription}<br />\n" \
                f"Reason : {newStateReason}<br />\n"

        # print(f"Processed message {message}")

        sns_client = boto3.client('sns')
	# raise ValueError('Could not find teams_url tag in SNS topic tags')
        url = "https://companyname.webhook.office.com/webhookb2/459f6ddf2b90f@d56477678cc0bb89aa/IncomingWebhook/6762774523dc510/8771a56c-83d1219fe5ac"
    
        payload = {
            "@type": "MessageCard",
            "@context": "http://schema.org/extensions",
            "themeColor": "0072C6",
            "summary": subject,
            "sections": [{
                "activityTitle": subject,
                "activitySubtitle": "",
                "activityImage": "",
                "text": body
            }]
        }
    
        # Send the payload to Teams
        encoded_msg = json.dumps(payload).encode("utf-8")
        resp = http.request("POST", url, body=encoded_msg)
    

        
    except Exception as e:
        print("An error occurred")
        raise e





