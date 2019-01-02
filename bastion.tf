# Reference: https://www.davidbegin.com/creating-an-aws-bastion-host-with-terraform/


resource "aws_security_group" "bastion-sg" {
  count 		= "${var.create_bastion == "yes" ? 1 : 0}"
  name   		= "bastion-security-group"
  vpc_id 		= "${aws_vpc.main.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "bastion_key" {
  count = "${var.create_bastion == "yes" ? 1 : 0}"
  key_name   = "bastion-${var.environment}"
  public_key = "${var.public_keypair}"
}

resource "aws_instance" "bastion" {
  count                       = "${var.create_bastion == "yes" ? 1 : 0}"
  ami                         = "${var.bastion_ami}"
  key_name                    = "${aws_key_pair.bastion_key.key_name}"
  instance_type               = "t2.micro"
  security_groups             = ["${aws_security_group.bastion-sg.id}"]
  subnet_id                   = "${aws_subnet.main-public-1.id}"
  associate_public_ip_address = true

  tags {
    Name = "bastion-${var.environment}"
  }
}

