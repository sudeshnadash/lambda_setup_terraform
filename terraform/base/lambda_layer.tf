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
  filename   = local.layer_zip_path
  layer_name          = local.layer_name
  compatible_runtimes = ["python3.8", "python3.9", "python3.10"]
  depends_on = [data.archive_file.custom_lambda_layer]
}
