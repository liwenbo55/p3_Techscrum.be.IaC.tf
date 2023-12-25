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
  description = "The name of the route53 hosted zone. Generally, hosted zone should be created before terraform provision."
  type        = string
}
