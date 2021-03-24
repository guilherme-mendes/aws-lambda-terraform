resource "aws_api_gateway_method" "get_employee" {
  rest_api_id   = aws_api_gateway_rest_api.employee_apigw.id
  resource_id   = aws_api_gateway_resource.employee.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_lambda_function" "GetEmployeeHandler" {

  function_name = "GetEmployeeHandler"

  filename = "../lambda/get_employee_lambda.zip"

  handler = "get_employee.lambda_handler"
  runtime = "python3.8"

  environment {
    variables = {
      REGION        = "us-east-1"
      EMPLOYEE_TABLE = aws_dynamodb_table.employee_table.name
   }
  }

  source_code_hash = filebase64sha256("../lambda/get_employee_lambda.zip")

  role = aws_iam_role.EmployeeLambdaRole.arn

  timeout     = "5"
  memory_size = "128"

}

resource "aws_api_gateway_integration" "get_employee-lambda" {

  rest_api_id = aws_api_gateway_rest_api.employee_apigw.id
  resource_id = aws_api_gateway_method.get_employee.resource_id
  http_method = aws_api_gateway_method.get_employee.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  uri = aws_lambda_function.GetEmployeeHandler.invoke_arn
}

resource "aws_lambda_permission" "apigw-GetEmployeeHandler" {
  
  action        = "lambda:GetActivityFunction"
  function_name = aws_lambda_function.GetEmployeeHandler.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.employee_apigw.execution_arn}/*/GET/employee"
}

resource "aws_api_gateway_deployment" "getemployeeapistageprod" {
  
  depends_on = [
    aws_api_gateway_integration.get_employee-lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.employee_apigw.id
  stage_name  = "prod"
}