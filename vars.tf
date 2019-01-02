variable "aws_profile" {
  type = "string"
  default = "default"
}

variable "aws_region" {
  type = "string"
  default = "us-east-1"
}

variable "public_keypair" {
  type = "string"
  default = "ssh-rsa xxx"
}

variable "notify_email" {
  type = "string"
  default = "infrastructure@pokt.network"
}

variable "environment" {
  type = "string"
  default = "prod"
}

variable "create_bastion" {
  type = "string"
  default = "no"
}


variable "pocket_instancetype" {
  type = "string"
  default = "t3.small"
}

variable "node_instancetype" {
  type = "string"
  default = "t3.large"
}

variable "platform" {
  type = "string"
  default = "64bit Amazon Linux 2018.03 v2.11.6 running Multi-container Docker 18.06.1-ce (Generic)" 

}

variable "bastion_ami" {
  type = "string"
  default = "ami-02a332807adca7555"

}
