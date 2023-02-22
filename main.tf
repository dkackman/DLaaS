terraform {
  backend "remote" {
    organization = "TaylorDigitalServices"

    workspaces {
      name = "DatalayerStorageService"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

module "service-user" {
  source                     = "./modules/service.user"

  # AWS Profile
  aws_access_key              = var.aws_access_key
  aws_secret_key              = var.aws_secret_key
  aws_region                  = var.aws_region
  aws_profile                 = var.aws_profile

  # Storage
  storage_bucket_id           = aws_s3_bucket.storage-bucket.id
  dev_bucket_id               = aws_s3_bucket.storage-devops-bucket.id

  # Network
  public_subnet_id            = aws_subnet.public-2.id

  # Policies And Roles
  default_lambda_role_arn     = aws_iam_role.default-lambda-role.arn
  
  # API Root
  api_gateway_id              = aws_api_gateway_rest_api.main.id
  root_resource_id            = aws_api_gateway_rest_api.main.root_resource_id
  api_gateway_arn             = aws_api_gateway_rest_api.main.execution_arn

  # Security
  allow_ssh_security_group_id = aws_security_group.allow-ssh-security-group.id

  # EC2 - Compute
  worker_ami                  = var.worker_ami
}

module "service-worker-gateway" {
  source                      = "./modules/service.worker-gateway"

    # AWS Profile
  aws_access_key              = var.aws_access_key
  aws_secret_key              = var.aws_secret_key
  aws_region                  = var.aws_region
  aws_profile                 = var.aws_profile

  # Policies And Roles
  default_lambda_role_arn     = aws_iam_role.default-lambda-role.arn
}