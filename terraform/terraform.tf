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
