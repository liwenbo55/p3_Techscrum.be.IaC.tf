variable "backend_fqdn" {
  description = "The fully qualified domain name of the endpoint to be checked."
  type        = string
}

variable "project_name" {
  description = "The project name."
  type        = string
}

variable "environment" {
  description = "The environment name."
  type        = string
}

variable "alb_arn_suffix" {
  description = "The loadbalancer arn."
  type        = string
}

variable "alb_target_group_arn_suffix" {
  description = "The loadbalancer target group arn."
  type        = string
}
