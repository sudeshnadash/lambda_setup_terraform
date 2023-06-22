variable "aws_profile" {
  description = "aws profile for deployment"
}

variable "aws_region" {
  description = "aws region for deployment"
}

variable "stage" {
  description = "Name of the stage"
  validation {
    condition = contains([
      "local-xxxx",
      "qa",
      "dev",
      "staging",
      "prod"
    ], var.stage)
    error_message = "Argument \"stage\" must be either \"sandbox\", \"dev\", \"qa\", \"staging\" or \"prod\"."
  }
}

variable "project" {
  type        = string
  description = "Main project or application name"
}

variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

