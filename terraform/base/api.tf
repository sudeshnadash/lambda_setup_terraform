resource "aws_s3_bucket" "lambda_bucket" {
  #checkov:skip=CKV2_AWS_62:Ensure S3 buckets should have event notifications enabled
  #checkov:skip=CKV_AWS_18:Ensure the S3 bucket has access logging enabled
  #checkov:skip=CKV_AWS_144:Ensure that S3 bucket has cross-region replication enabled
  #checkov:skip=CKV_AWS_21:Ensure all data stored in the S3 bucket have versioning enabled
  #checkov:skip=CKV2_AWS_6:Ensure that S3 bucket has a Public Access block
  #checkov:skip=CKV_AWS_145:Ensure that S3 buckets are encrypted with KMS by default
  #checkov:skip=CKV2_AWS_61:Ensure that an S3 bucket has a lifecycle configuration
  bucket = "${var.stage}-${var.project}-lambda"
}

data "archive_file" "lambda_zip" {
  type = "zip"

  source_dir  = "../../../src"
  output_path = "../../../src.zip"
}

resource "aws_s3_object" "lambda_dashboard" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "src.zip"
  source = data.archive_file.lambda_dashboard.output_path

  etag = filemd5(data.archive_file.lambda_dashboard.output_path)
}

#################################################################################
#                                                                               #
#                               LAMBDA FUNCTIONS                                #
#                                                                               #
#################################################################################
# list_dashboards
resource "aws_lambda_function" "list_dashboards" {
  function_name = "create_student"

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
    aws_lambda_layer_version.custom_layer.arn
  ]

  source_code_hash = data.archive_file.lambda_dashboard.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      POWERTOOLS_SERVICE_NAME = "${var.stage}-${var.project}",
      LOG_LEVEL : "INFO",
      DASHBOARD_TABLE_NAME    = aws_dynamodb_table.dashboards.id
    }
  }
}
resource "aws_cloudwatch_log_group" "list_dashboards" {
  #checkov:skip=CKV_AWS_338:Ensure CloudWatch log groups retains logs for at least 1 year
  #checkov:skip=CKV_AWS_158:Ensure that CloudWatch Log Group is encrypted by KMS
  name              = "/aws/lambda/${aws_lambda_function.list_dashboards.function_name}"
  retention_in_days = 30
}


#### SAVE DASHBOARD FUNCTION #########
resource "aws_lambda_function" "save_dashboard" {
  #checkov:skip=CKV_AWS_272:Ensure AWS Lambda function is configured to validate code-signing
  #checkov:skip=CKV_AWS_115:Ensure that AWS Lambda function is configured for function-level concurrent execution limit
  #checkov:skip=CKV_AWS_117:Ensure that AWS Lambda function is configured inside a VPC
  #checkov:skip=CKV_AWS_116:Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)
  #checkov:skip=CKV_AWS_173:Check encryption settings for Lambda environmental variable
  function_name = "${var.stage}-${var.project}-saveDashboard"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_dashboard.key

  architectures = ["arm64"]
  runtime       = "python3.10"
  handler       = "api/handlers/save_dashboard.handler"
  memory_size   = 256
  tracing_config {
    mode = "Active"
  }
  layers = [
    "arn:aws:lambda:${var.aws_region}:017000801446:layer:AWSLambdaPowertoolsPythonV2-Arm64:32",
    aws_lambda_layer_version.custom_layer.arn
  ]

  source_code_hash = data.archive_file.lambda_dashboard.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      POWERTOOLS_SERVICE_NAME = "${var.stage}-${var.project}",
      LOG_LEVEL : "INFO",
      DASHBOARD_TABLE_NAME    = aws_dynamodb_table.dashboards.id
      DASHBOARD_TABLE_REGION  = "us-east-1"
    }
  }
}
resource "aws_cloudwatch_log_group" "save_dashboard" {
  #checkov:skip=CKV_AWS_338:Ensure CloudWatch log groups retains logs for at least 1 year
  #checkov:skip=CKV_AWS_158:Ensure that CloudWatch Log Group is encrypted by KMS
  name              = "/aws/lambda/${aws_lambda_function.save_dashboard.function_name}"
  retention_in_days = 30
}


# get_dashboard
resource "aws_lambda_function" "get_dashboard" {
  #checkov:skip=CKV_AWS_272:Ensure AWS Lambda function is configured to validate code-signing
  #checkov:skip=CKV_AWS_115:Ensure that AWS Lambda function is configured for function-level concurrent execution limit
  #checkov:skip=CKV_AWS_117:Ensure that AWS Lambda function is configured inside a VPC
  #checkov:skip=CKV_AWS_116:Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)
  #checkov:skip=CKV_AWS_173:Check encryption settings for Lambda environmental variable
  function_name = "${var.stage}-${var.project}-getDashboard"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_dashboard.key

  architectures = ["arm64"]
  runtime       = "python3.10"
  handler       = "api/handlers/get_dashboard.handler"
  memory_size   = 256
  tracing_config {
    mode = "Active"
  }
  layers = [
    "arn:aws:lambda:${var.aws_region}:017000801446:layer:AWSLambdaPowertoolsPythonV2-Arm64:32",
    aws_lambda_layer_version.custom_layer.arn
  ]

  source_code_hash = data.archive_file.lambda_dashboard.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
  environment {
    variables = {
      POWERTOOLS_SERVICE_NAME = "${var.stage}-${var.project}",
      LOG_LEVEL : "INFO",
      DASHBOARD_TABLE_NAME    = aws_dynamodb_table.dashboards.id
    }
  }
}
resource "aws_cloudwatch_log_group" "get_dashboard" {
  #checkov:skip=CKV_AWS_338:Ensure CloudWatch log groups retains logs for at least 1 year
  #checkov:skip=CKV_AWS_158:Ensure that CloudWatch Log Group is encrypted by KMS
  name              = "/aws/lambda/${aws_lambda_function.get_dashboard.function_name}"
  retention_in_days = 30
}


#################################################################################
#                                                                               #
#                               API GATEWAY REST                                #
#                                                                               #
#################################################################################

# root resource
resource "aws_api_gateway_rest_api" "dashboard_api" {
  #checkov:skip=CKV2_AWS_29:Ensure public API gateway are protected by WAF
  #checkov:skip=CKV_AWS_237:Ensure Create before destroy for API GATEWAY
  name = "${var.stage}-${var.project}-api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on  = [
    aws_api_gateway_integration.list_dashboards, aws_api_gateway_integration.get_dashboard,
    aws_api_gateway_integration.save_dashboard
  ]
  rest_api_id = aws_api_gateway_rest_api.dashboard_api.id
  lifecycle {
    create_before_destroy = true
  }
  triggers = {
    redeployment = sha1(jsonencode([
      jsonencode(aws_api_gateway_integration.save_dashboard),
      jsonencode(aws_api_gateway_integration.list_dashboards),
      jsonencode(aws_api_gateway_integration.get_dashboard)
    ]))
  }
}

resource "aws_api_gateway_stage" "stage" {
  #checkov:skip=CKV2_AWS_51:Ensure AWS API Gateway endpoints uses client certificate authentication
  #checkov:skip=CKV2_AWS_4:Ensure Ensure API Gateway stage have logging level defined as appropriate
  #checkov:skip=CKV_AWS_120:Ensure API Gateway caching is enabled
  #checkov:skip=CKV_AWS_73:Ensure API Gateway has X-Ray Tracing enabled
  #checkov:skip=CKV_AWS_76:Ensure API Gateway has Access Logging enabled
  #checkov:skip=CKV2_AWS_29:Ensure public API gateway are protected by WAF
  stage_name    = "${var.stage}"
  rest_api_id   = "${aws_api_gateway_rest_api.dashboard_api.id}"
  deployment_id = "${aws_api_gateway_deployment.deployment.id}"
}

# dashboard resource (corresponding to path /dashboards)
resource "aws_api_gateway_resource" "list_dashboards" {
  path_part   = "dashboards"
  parent_id   = aws_api_gateway_rest_api.dashboard_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.dashboard_api.id
}

# GATEWAY METHOD
resource "aws_api_gateway_method" "list_dashboards" {
  #checkov:skip=CKV2_AWS_53:EEnsure AWS API gateway request is validated
  #checkov:skip=CKV_AWS_59:Ensure there is no open access to back-end resources through API
  rest_api_id   = "${aws_api_gateway_rest_api.dashboard_api.id}"
  resource_id   = "${aws_api_gateway_resource.list_dashboards.id}"
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_method" "save_dashboard" {
  #checkov:skip=CKV2_AWS_53:EEnsure AWS API gateway request is validated
  #checkov:skip=CKV_AWS_59:Ensure there is no open access to back-end resources through API
  rest_api_id   = "${aws_api_gateway_rest_api.dashboard_api.id}"
  resource_id   = "${aws_api_gateway_resource.list_dashboards.id}"
  http_method   = "POST"
  authorization = "NONE"
}

# INTEGRATION
resource "aws_api_gateway_integration" "list_dashboards" {
  rest_api_id             = aws_api_gateway_rest_api.dashboard_api.id
  resource_id             = aws_api_gateway_resource.list_dashboards.id
  http_method             = aws_api_gateway_method.list_dashboards.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.list_dashboards.invoke_arn
}
resource "aws_api_gateway_integration" "save_dashboard" {
  rest_api_id             = aws_api_gateway_rest_api.dashboard_api.id
  resource_id             = aws_api_gateway_resource.list_dashboards.id
  http_method             = aws_api_gateway_method.save_dashboard.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.save_dashboard.invoke_arn
}


###########################################

resource "aws_api_gateway_resource" "dashboards_id" {
  rest_api_id = aws_api_gateway_rest_api.dashboard_api.id
  parent_id   = aws_api_gateway_resource.list_dashboards.id
  path_part   = "{dashboardId}"
}

# get_dashboard
resource "aws_api_gateway_method" "get_dashboard" {
  #checkov:skip=CKV2_AWS_53:Ensure AWS API gateway request is validated
  #checkov:skip=CKV_AWS_59:Ensure there is no open access to back-end resources through API
  rest_api_id   = "${aws_api_gateway_rest_api.dashboard_api.id}"
  resource_id   = "${aws_api_gateway_resource.dashboards_id.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_dashboard" {
  rest_api_id             = aws_api_gateway_rest_api.dashboard_api.id
  resource_id             = aws_api_gateway_resource.dashboards_id.id
  http_method             = aws_api_gateway_method.get_dashboard.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_dashboard.invoke_arn
}

# widgets resource (corresponding to path /dashboard/{dashboardId}/widgets)
resource "aws_api_gateway_resource" "widgets" {
  rest_api_id = aws_api_gateway_rest_api.dashboard_api.id
  parent_id   = aws_api_gateway_resource.dashboards_id.id
  path_part   = "widgets"
}

# widgets by Id resource (corresponding to path /dashboard/{dashboardId}/widgets/{widgetId})
resource "aws_api_gateway_resource" "widgets_id" {
  rest_api_id = aws_api_gateway_rest_api.dashboard_api.id
  parent_id   = aws_api_gateway_resource.widgets.id
  path_part   = "{widgetId}"
}


#endregion
