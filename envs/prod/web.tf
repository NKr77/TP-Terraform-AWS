module "web" {
  source = "git::https://github.com/NKr77/TP-Terraform-AWS.git//modules/web?ref=web-v2.0.0"

  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnets
  instance_type             = var.instance_type
  ami_id                    = var.ami_id
  aws_region                = var.region
  app_secret_parameter_name = aws_ssm_parameter.app_secret.name
}
