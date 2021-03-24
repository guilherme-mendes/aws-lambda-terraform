import logging
import boto3
import json
import os


session = boto3.Session(region_name=os.environ['REGION'])
dynamodb_client = session.client('dynamodb')

def lambda_handler(event, context):
    try:

        payload = json.loads(event["body"])
        print("payload ->" + str(payload))
        dynamodb_response = dynamodb_client.put_item(
            TableName=os.environ["EMPLOYEE_TABLE"],
            Item={
                "id": {
                    "S": payload["id"]
                },
                "role": {
                    "S": payload["role"]
                },
                "age": {
                    "N": str(payload["age"])
                },
                "name": {
                    "S": payload["name"]
                }
            }
        )
        print(dynamodb_response)
        return {
            'statusCode': 201,
           'body': '{"status":"Employee created!"}'
        }
    except Exception as e:
        logging.error(e)
        return {
            'statusCode': 500,
           'body': '{"status":"Server error!"}'
        }