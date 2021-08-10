variable "region" {
  default     = "" # Put your region here
  description = "main region"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public1_cidr_block" {
  default = "10.0.96.0/24"
}

variable "public2_cidr_block" {
  default = "10.0.97.0/24"
}

variable "private1_cidr_block" {
  default = "10.0.0.0/19"
}

variable "private2_cidr_block" {
  default = "10.0.32.0/19"
}

variable "ami" {
  default = "ami-0f8243a5175208e08" #Amazon Linux 2
}

variable "key" {
  default = "" #Put your amazon key here
}

variable "instance-tp" {
  default = "t2.micro"
}