import boto3
import os
import json
import logging


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("employee")


def lambda_handler(event, context):

    dynamodb = boto3.client('dynamodb')
    paginator = dynamodb.get_paginator('scan')
    params = {"TableName": os.environ.get('EMPLOYEE_TABLE')}

    items = []
    for page in paginator.paginate(**params):
        items.append(page['Items'])

    resp = {
        "statusCode": 200,
        "body": json.dumps(items)
    }
    
    logger.info(f"resp: {resp}")

    return resp