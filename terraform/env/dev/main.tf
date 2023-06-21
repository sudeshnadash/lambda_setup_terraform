locals {
  stage       = "dev"
  aws_region  = "us-east-1"
  aws_profile = "poc_aws_profile"
  project     = "poc_student"
  account_id  = "544251493436"
}

module "base" {
  source = "../../base"

  aws_profile = local.aws_profile

  stage      = local.stage
  aws_region = local.aws_region

  project = local.project
  
  account_id  = local.account_id

  #DynamoDB
  deletion_protection      = false

}
