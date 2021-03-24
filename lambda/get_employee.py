import os
import json
import boto3


def lambda_handler(event, context):

    client = boto3.client('dynamodb')

    response = client.scan(TableName=os.environ['EMPLOYEE_TABLE']);
    employee_result_items = response["Items"]

    employee_results = []

    for employee_result_item in employee_result_items:
        id = employee_result_item["id"]["S"]
        name = employee_result_item["name"]["S"]
        age = employee_result_item["age"]["N"]
        role = employee_result_item["role"]["S"]

        employee_results.append({
            'id': id,
            'name': name,
            'age': age,
            'role': role
        })

    response = {
        'statusCode': 200,
        'headers': {
            "x-custom-header": "my custom header value",
            "Access-Control-Allow-Origin": "*"
        },
        'body': json.dumps(employee_results)
    }

    return response
