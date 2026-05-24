variable "environment" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "c7i-flex.large"
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}
