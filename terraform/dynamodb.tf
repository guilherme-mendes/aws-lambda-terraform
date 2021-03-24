provider "aws" {
  profile = "default"
  region  = "us-east-1"
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

data "aws_iam_policy_document" "EmployeeLambdaPolicyDocument" {

  statement {
    actions = [
      "*"
    ]

    effect = "Allow"

    resources = [
      aws_dynamodb_table.employee_table.arn,
      "arn:aws:logs:*"
    ]

    sid = "lambdadynamodb"
  }
}