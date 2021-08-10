locals {
  app_instance = "drupal"
  host = "bastion_host"

}

resource "aws_instance" "bastion1" {
  ami = var.ami
  key_name = var.key
  instance_type = var.instance-tp
  vpc_security_group_ids = ["${aws_security_group.public.id}"]
  associate_public_ip_address = true
  subnet_id = aws_subnet.public_1.id
  availability_zone = "${var.region}a"

  tags = {
    Name = "${local.host}1"
  }
}

resource "aws_instance" "bastion2" {
  ami = var.ami
  key_name = var.key
  instance_type = var.instance-tp
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.public.id}"]
  subnet_id = aws_subnet.public_2.id
  availability_zone = "${var.region}c"

  tags = {
      Name = "${local.host}2"
  }
}

resource "aws_instance" "drupal1" {
  ami = var.ami
  key_name = var.key
  instance_type = var.instance-tp
  vpc_security_group_ids = ["${aws_security_group.app-drupal.id}"]
  subnet_id = aws_subnet.private_1.id
  availability_zone = "${var.region}a"

  tags = {
      Name = "${local.app_instance}1"
  }
}

resource "aws_instance" "drupal2" {
  ami = var.ami
  key_name = var.key
  instance_type = var.instance-tp
  vpc_security_group_ids = ["${aws_security_group.app-drupal.id}"]
  subnet_id = aws_subnet.private_2.id
  availability_zone = "${var.region}c"

  tags = {
      Name = "${local.app_instance}2"
  }
}