terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.33.0" # Terraform AWS Provider version 6.33.0 is compatible with Terraform 1.7.0 and later versions.
    }
    
  }

    backend "s3" {
    bucket         = "remote-state-daws-8686-dev"
    key            = "roboshop-dev-sg-db"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile     = true
    #dynamodb_table = "terraform-state-lock-table"
  }

}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
