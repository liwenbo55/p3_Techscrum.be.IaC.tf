variable "project_name" {
  description = "The project name."
  type        = string
}
variable "environment" {
  description = "The environment name."
  type        = string
}
# variable "description_alb_sg" {
#   description = "Description for ALB security group."
#   type        = string
#   default     = "Allow http (port80) from any source. "
# }
variable "sg_vpc_id" {
  description = "VPC ID."
  type        = string
}
