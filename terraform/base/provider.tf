# module "tags" {
#   source  = "git::https://dev.azure.com/skfdc/REP-SW/_git/terraform-modules//modules/tags?ref=20.2.2"
#   team    = "QA-Team"
#   service = local.service
#   status  = var.stage
# }

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
  # default_tags {
  #   tags = module.tags.values
  # }
}