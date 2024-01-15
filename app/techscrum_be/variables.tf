variable "aws_region" {
  description = "aws_region"
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

variable "hosted_zone_name" {
  description = "Used for Load Balancer. The name of the route53 hosted zone. Generally, hosted zone should be created before terraform provision."
  type        = string
}

variable "sns_email" {
  description = "An email address to send data in SNS service."
  type        = string
}
