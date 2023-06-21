terraform {
  backend "s3" {
    encrypt        = "true"
    bucket         = "terraform-state-storage-hkjhku878lkh"
    dynamodb_table = "terraform-state-lock-kjhjk8897khkg"
    key            = "lambda-setup/dev/terraform.tfstate"
    region         = "us-east-1"
    profile        = "lambda_setup_ci"
  }
}
