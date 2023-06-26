data "archive_file" "lambda_zip" {
  type = "zip"

  source_dir  = "../../../src"
  output_path = "../../../src.zip"
}
resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.stage}-create_student"
  filename   = data.archive_file.lambda_zip.output_path
  description   = "My awesome lambda function"
  architectures = ["arm64"]
  runtime       = "python3.10"
  handler       = "create_student.lambda_handler"
  memory_size   = 256
  publish       = true
  tags = {
    Module = "lambda-with-layer"
  }
  tracing_config {
    mode = "Active"
  }
  layers = [
    aws_lambda_layer_version.my_layer.arn
  ]

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.my_role.arn
  depends_on = [aws_lambda_layer_version.my_layer]
}
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "my_role" {
  name = "my-lambda-role"
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

#define variables
locals {
  layer_zip_path    = "my_layer.zip"
  layer_name        = "my_lambda_layer"
  path_to_custom_layer = "../../../layer"
  requirements_file_name = "requirements.txt"
}


data "archive_file" "custom_lambda_layer" {
  type = "zip"

  source_dir  = local.path_to_custom_layer
  output_path = "../../../${local.layer_zip_path}"
}

# upload zip file
resource "aws_lambda_layer_version" "my_layer" {
  filename   = data.archive_file.custom_lambda_layer.output_path
  layer_name          = local.layer_name
  compatible_runtimes = ["python3.8", "python3.9", "python3.10"]
  depends_on = [data.archive_file.custom_lambda_layer]
}
