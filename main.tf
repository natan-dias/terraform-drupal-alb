provider "aws" {
  region = var.region
}

locals {
  app = "drupal"
  manager = "bastion"
  tags = {
    Environment = "dev"
    Owner = "devops"
    Work  = "graduate"
  }
}

resource "aws_vpc" "dev" {
  cidr_block = var.vpc_cidr_block

  tags = local.tags

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev.id

  tags = local.tags
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = var.public1_cidr_block
  availability_zone = "${var.region}a"

  tags = {
    Name = "Public 1a"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = var.public2_cidr_block
  availability_zone = "${var.region}c"

  tags = {
    Name = "Public 2b"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = var.private1_cidr_block
  availability_zone = "${var.region}a"

  tags = {
    Name = "Private 1a"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = var.private2_cidr_block
  availability_zone = "${var.region}c"

  tags = {
    Name = "Private 2b"
  }
}


resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
      
  }

  tags = local.tags

}

resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.dev.id

  tags = local.tags
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_security_group" "public" {
  name        = local.manager
  description = "Allow management from Bastion"
  vpc_id      = aws_vpc.dev.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [""] #Put only your local IP, for security
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ManagerSG"
  }
}

resource "aws_security_group" "alb" {
  name        = "ALB-SG"
  description = "Load Balance Security Group"
  vpc_id      = aws_vpc.dev.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Load Balancer"
  }
}

resource "aws_security_group" "app-drupal" {
  name        = local.app
  description = "Allow incoming application connections"
  vpc_id      = aws_vpc.dev.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.public1_cidr_block}","${var.public2_cidr_block}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }

  ingress { #Only for test environment
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.public1_cidr_block}","${var.public2_cidr_block}"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags

}

resource "aws_efs_file_system" "drupalFS" {
  creation_token = "drupalFS"

  tags = {
    Name = "Drupal File System"
  }
}