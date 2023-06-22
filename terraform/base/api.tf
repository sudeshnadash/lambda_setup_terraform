resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.stage}-lambda"
}

data "archive_file" "lambda_zip" {
  type = "zip"

  source_dir  = "../../../src"
  output_path = "../../../src.zip"
}

resource "aws_s3_object" "lambda_s3" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "src.zip"
  source = data.archive_file.lambda_zip.output_path

  etag = filemd5(data.archive_file.lambda_dashboard.output_path)
}

#################################################################################
#                                                                               #
#                               LAMBDA FUNCTIONS                                #
#                                                                               #
#################################################################################
# list_dashboards
resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.stage}-create_student"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_dashboard.key

  architectures = ["arm64"]
  runtime       = "python3.10"
  handler       = "api/handlers/create_student.lambda_handler"
  memory_size   = 256
  tracing_config {
    mode = "Active"
  }
  layers = [
    "arn:aws:lambda:${var.aws_region}:017000801446:layer:AWSLambdaPowertoolsPythonV2-Arm64:32",
    aws_lambda_layer_version.my_layer.arn
  ]

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 30
}

#################################################################################
#                                                                               #
#                               API GATEWAY REST                                #
#                                                                               #
#################################################################################

# root resource
resource "aws_api_gateway_rest_api" "lambda_api" {
  name = "${var.stage}-api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_stage" "stage" {
  stage_name    = "${var.stage}"
  rest_api_id   = "${aws_api_gateway_rest_api.lambda_api.id}"
  deployment_id = "${aws_api_gateway_deployment.deployment.id}"
}

# API Gateway Resource
resource "aws_api_gateway_resource" "api_resource" {
  path_part   = "student"
  parent_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
}

# GATEWAY METHOD
resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.lambda_api.id}"
  resource_id   = "${aws_api_gateway_resource.api_resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

# INTEGRATION
resource "aws_api_gateway_integration" "api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_api.id
  resource_id             = aws_api_gateway_resource.api_resource.id
  http_method             = aws_api_gateway_method.api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on  = [
    aws_api_gateway_integration.api_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  lifecycle {
    create_before_destroy = true
  }
  triggers = {
    redeployment = sha1(jsonencode([
      jsonencode(aws_api_gateway_integration.api_integration)
    ]))
  }
}


#endregion
