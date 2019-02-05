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
  default = "ssh-rsa xxxx"
}

variable "notify_email" {
  type = "string"
}

variable "environment" {
  type = "string"
}

variable "create_bastion" {
  type = "string"
}


variable "pocket_instancetype" {
  type = "string"
  default = "t3.small"
}

variable "node_instancetype" {
  type = "string"
  default = "t3.xlarge"
}

variable "platform" {
  type = "string"
  default = "64bit Amazon Linux 2018.03 v2.11.7 running Multi-container Docker 18.06.1-ce (Generic)" 

}

variable "bastion_ami" {
  type = "string"
  default = "ami-02a332807adca7555"

#  us-east-2: ami-d54378b0
#  us-east-1: ami-02a332807adca7555
#  us-west-1: ami-d54378b0
}
