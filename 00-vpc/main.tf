module "vpc" {
  source      = "../../terraform-aws-vpc"
  #source      = "git::https://github.com/gopal-gunji/terraform-aws-vpc.git?ref=main"
  project     = var.project
  environment = var.environment
  is_peering_required = true
}

