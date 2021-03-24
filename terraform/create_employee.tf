resource "aws_api_gateway_method" "create_employee" {
  rest_api_id   = aws_api_gateway_rest_api.employee_apigw.id
  resource_id   = aws_api_gateway_resource.employee.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_lambda_function" "CreateEmployeeHandler" {

  function_name = "CreateEmployeeHandler"

  filename = "../lambda/create_employee_lambda.zip"

  handler = "create_employee.lambda_handler"
  runtime = "python3.8"

  environment {
    variables = {
      REGION        = "us-east-1"
      EMPLOYEE_TABLE = aws_dynamodb_table.employee_table.name
   }
  }

  source_code_hash = filebase64sha256("../lambda/create_employee_lambda.zip")

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