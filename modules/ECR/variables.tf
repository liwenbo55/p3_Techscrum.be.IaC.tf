variable "project_name" {
  description = "The project name."
  type        = string
}

variable "environment" {
  description = "The environment name."
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE. Defaults to MUTABLE."
  default     = "MUTABLE"
  type        = string
}

variable "force_delete" {
  description = "If true, will delete the repository even if it contains images. Defaults to false."
  type        = bool
  default     = true
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)."
  type        = bool
  default     = true
}
