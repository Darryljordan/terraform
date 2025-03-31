module "km-kn-module-tp-aws" {
  source = "../normal"
}

variable "prefix" {
  type = string
  default = "km-kn"
}

variable "suffix" {
  type = string
  default = "terra-module-tp-aws"
}

variable "ami" {
  type    = string
  default = "ami-08f9a9c699d2ab3f9"
}