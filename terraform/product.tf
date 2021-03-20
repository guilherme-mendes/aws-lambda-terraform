provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_dynamodb_table" "employee_table" {

  name         = "EMPLOYEE"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "role"
    type = "S"
  }

  attribute {
    name = "age"
    type = "N"
  }

  global_secondary_index {
    name            = "EmployeeRoleAgeIndex"
    hash_key        = "role"
    range_key       = "age"
    projection_type = "ALL"
  }

}

resource "aws_api_gateway_rest_api" "employee_apigw" {
  name        = "employee_apigw"
  description = "Employee API Gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "employee" {
  rest_api_id = aws_api_gateway_rest_api.employee_apigw.id
  parent_id   = aws_api_gateway_rest_api.employee_apigw.root_resource_id
  path_part   = "employee"
}

resource "aws_api_gateway_method" "create_employee" {
  rest_api_id   = aws_api_gateway_rest_api.employee_apigw.id
  resource_id   = aws_api_gateway_resource.employee.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_iam_role" "EmployeeLambdaRole" {
  name               = "EmployeeLambdaRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "template_file" "employeelambdapolicy" {
  template = file("${path.module}/policy.json")
}

resource "aws_iam_policy" "EmployeeLambdaPolicy" {
  name        = "EmployeeLambdaPolicy"
  path        = "/"
  description = "IAM policy for Employee lambda functions"
  policy      = data.template_file.employeelambdapolicy.rendered
}

resource "aws_iam_role_policy_attachment" "EmployeeLambdaRolePolicy" {
  role       = aws_iam_role.EmployeeLambdaRole.name
  policy_arn = aws_iam_policy.EmployeeLambdaPolicy.arn
}

resource "aws_lambda_function" "CreateEmployeeHandler" {

  function_name = "CreateEmployeeHandler"

  filename = "../lambda/employee_lambda.zip"

  handler = "create_employee.lambda_handler"
  runtime = "python3.8"

  environment {
    variables = {
      REGION        = "us-east-2"
      EMPLOYEE_TABLE = aws_dynamodb_table.employee_table.name
   }
  }

  source_code_hash = filebase64sha256("../lambda/employee_lambda.zip")

  role = aws_iam_role.EmployeeLambdaRole.arn

  timeout     = "5"
  memory_size = "128"

}

resource "aws_api_gateway_integration" "create_employee-lambda" {

  rest_api_id = aws_api_gateway_rest_api.employee_apigw.id
  resource_id = aws_api_gateway_method.create_employee.resource_id
  http_method = aws_api_gateway_method.create_employee.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  uri = aws_lambda_function.CreateEmployeeHandler.invoke_arn
}

resource "aws_lambda_permission" "apigw-CreateEmployeeHandler" {

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.CreateEmployeeHandler.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.employee_apigw.execution_arn}/*/POST/employee"
}

resource "aws_api_gateway_deployment" "employeeapistageprod" {

  depends_on = [
    aws_api_gateway_integration.create_employee-lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.employee_apigw.id
  stage_name  = "prod"
}
