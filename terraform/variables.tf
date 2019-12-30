provider "aws" {

}

variable "vpc_id" {
  type = string
  default = null
}

variable "cluster_name" {
  type = string
}

variable "security_groups" {
  type = list(string)
  default = []
}

variable "num_slaves" {
  type = number
}

variable "user_data" {
  type = string
  default = null
}

variable "availability_zone" {
  type = string
  default = null
}

variable "key_name" {
  type = string
}

variable "instace_type" {
  type = string
  default = "m5.large"
}

variable "volume_size" {
  type = number
  default = 30
}

variable "tenancy" {
  type = string
  default = "default"
}

variable "placement_group" {
  type = string
  default = null
}

variable "subnet_id" {
  type = string
  default = null
}

variable "instance_profile" {
  type = string
  default = null
}

variable "ebs_optimized" {
  type = bool
  default = false
}

variable "instance_shutdown_behavior" {
  type = string
  default = "stop"
}