#define variables
locals {
  layer_zip_path    = "my_layer.zip"
  layer_name        = "my_lambda_layer"
  path_to_custom_layer = "../../../layer"
  requirements_file_name = "requirements.txt"
}


data "archive_file" "custom_analytics_lambda_layer" {
  type = "zip"

  source_dir  = local.path_to_custom_layer
  output_path = "../../../${local.layer_zip_path}"
  depends_on = [null_resource.custom_analytics_lambda_layer]
}

# upload zip file to s3
resource "aws_s3_object" "lambda_layer_zip" {
  bucket     = aws_s3_bucket.lambda_bucket.id
  key        = local.layer_zip_path
  source     = data.archive_file.custom_analytics_lambda_layer.output_path
  depends_on = [data.archive_file.custom_analytics_lambda_layer] # triggered only if the zip file is created
}

# create lambda layer from s3 object
resource "aws_lambda_layer_version" "custom_layer" {
  s3_bucket           = aws_s3_bucket.lambda_bucket.id
  s3_key              = aws_s3_object.lambda_layer_zip.key
  layer_name          = local.layer_name
  compatible_runtimes = ["python3.9", "python3.10"]
  source_code_hash    = data.archive_file.custom_analytics_lambda_layer.output_base64sha256
  depends_on          = [aws_s3_object.lambda_layer_zip] # triggered only if the zip file is uploaded to the bucket
}
