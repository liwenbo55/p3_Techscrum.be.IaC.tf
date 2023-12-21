variable "project_name" {
  description = "The project name."
  type        = string
}
variable "environment" {
  description = "The environment name."
  type        = string
}
# vpc
variable "cidr_block" {
  description = "The IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

# subnets
variable "public_subnet_1_cidr_block" {
  description = "The IPv4 CIDR block for the public subnet 1."
  type        = string
  default     = "10.0.1.0/24"
}
variable "public_subnet_2_cidr_block" {
  description = "The IPv4 CIDR block for the public subnet 2."
  type        = string
  default     = "10.0.2.0/24"
}
variable "private_subnet_1_cidr_block" {
  description = "The IPv4 CIDR block for the private subnet 1."
  type        = string
  default     = "10.0.3.0/24"
}
variable "private_subnet_2_cidr_block" {
  description = "The IPv4 CIDR block for the private subnet 2."
  type        = string
  default     = "10.0.4.0/24"
}

variable "availability_zone_1" {
  description = "AZ 1 for the subnet."
  type        = string
  default     = "ap-southeast-2a"
}
variable "availability_zone_2" {
  description = "AZ 2 for the subnet."
  type        = string
  default     = "ap-southeast-2b"
}

# route table
variable "public_rt_destination" {
  description = "Destination for public route table. Set to 0.0.0.0/0 means any ip address other than local will be sent to internet gateway."
  type        = string
  default     = "0.0.0.0/0"
}

variable "private_rt_destination" {
  description = "Destination for private route table. Set to 0.0.0.0/0 means any ip address other than local will be sent to nat gateway (to public subnet)."
  type        = string
  default     = "0.0.0.0/0"
}
