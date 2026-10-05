module "web" {
  source = "git::https://github.com/NKr77/TP-Terraform-AWS.git//modules/web?ref=web-v1.0.0"

  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets
  instance_type     = var.instance_type
  ami_id            = var.ami_id
}
