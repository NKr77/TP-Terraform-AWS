module "web" {
  source = "../../modules/web"

  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets
  instance_type     = var.instance_type
}
