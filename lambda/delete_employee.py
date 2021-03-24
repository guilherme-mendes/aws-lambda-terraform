import boto3
import os
import json
import logging


logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb_client = boto3.resource('dynamodb')

def lambda_handler(event, context):
    logger.info('Removing employee...')
    
    table = dynamodb_client.Table(os.environ['EMPLOYEE_TABLE'])
    
    table.delete_item(
        Key={
            'id': event.get('id')
        }
    )

    response = {'result': 'OK'}

    return {
        'statusCode': '200',
        'body': json.dumps(response),
        'headers': {
            'Content-Type': 'application/json'
        }
    }
