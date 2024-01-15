provider "aws" {
  region = var.aws_region
}

data "aws_route53_zone" "hosted_zone" {
  name = var.hosted_zone_name
}

module "VPC" {
  source       = "../../modules/VPC"
  project_name = var.project_name
  environment  = var.environment
}

module "ECR" {
  source       = "../../modules/ECR"
  project_name = var.project_name
  environment  = var.environment
}

module "IAM" {
  source       = "../../modules/IAM"
  project_name = var.project_name
  environment  = var.environment

}

module "Security_Group" {
  source       = "../../modules/security_group"
  project_name = var.project_name
  environment  = var.environment
  sg_vpc_id    = module.VPC.vpc_id
}

module "ALB" {
  source                  = "../../modules/ALB"
  project_name            = var.project_name
  environment             = var.environment
  alb_security_groups     = [module.Security_Group.alb_security_group_id]
  alb_vpc_subnets         = [module.VPC.vpc_public_subnet_1_id, module.VPC.vpc_public_subnet_2_id]
  alb_target_group_vpc_id = module.VPC.vpc_id
  hosted_zone_id          = data.aws_route53_zone.hosted_zone.zone_id
  hosted_zone_name        = var.hosted_zone_name
}

module "ECS" {
  source                              = "../../modules/ECS"
  project_name                        = var.project_name
  environment                         = var.environment
  container_image                     = module.ECR.repository_url
  task_definition_execution_role_arn  = module.IAM.ecs_task_execution_role_arn
  ecs_service_vpc_subnets             = [module.VPC.vpc_private_subnet_1_id, module.VPC.vpc_private_subnet_2_id]
  ecs_service_network_security_groups = [module.Security_Group.ecs_security_group_id]
  ecs_service_target_group_arn        = module.ALB.alb_target_group_arn
}

module "Monitoring" {
  source       = "../../modules/Monitoring"
  project_name = var.project_name
  environment  = var.environment
  backend_fqdn = module.ALB.backend_fqdn
  alb_arn_suffix      = module.ALB.alb_arn_suffix
  alb_target_group_arn_suffix = module.ALB.alb_target_group_arn_suffix
  sns_email =var.sns_email
}