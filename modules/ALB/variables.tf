# load balancer
variable "project_name" {
  description = "The project name."
  type        = string
}
variable "environment" {
  description = "The environment name."
  type        = string
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to true."
  type        = bool
  default     = true
}

variable "alb_security_groups" {
  description = "A list of security group IDs to assign to the LB."
  type        = list(string)
}

variable "alb_vpc_subnets" {
  description = "A list of subnet IDs to attach to the LB. Public subnets should be picked."
  type        = list(string)
}

# load balancer target group
variable "alb_target_group_vpc_id" {
  description = "Identifier of the VPC in which to create the target group."
  type        = string
}

# A record for load balancer
variable "hosted_zone_id" {
  description = "The ID of the route53 hosted zone."
  type        = string
}

variable "record_type_A" {
  description = "A record. "
  type        = string
  default     = "A"
}

variable "evaluate_target_health" {
  type    = bool
  default = true
}

# ACM
variable "validation_method" {
  description = "Validation_method is set to 'DNS' by default."
  type        = string
  default     = "DNS"
}

variable "key_algorithm" {
  description = "key_algorithm is set to 'RSA_2048' by default."
  type        = string
  default     = "RSA_2048"
}

variable "ACM_validation_ttl" {
  description = "validation ttl is set to '300' by default."
  default     = 300
}
