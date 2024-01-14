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
