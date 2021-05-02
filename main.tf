terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.37.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name = var.labname

  cidr           = var.vpc_cidr
  azs            = var.vpc_azs
  public_subnets = var.vpc_public_subnets

  tags = var.lab_tag
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "1.0.0"

  key_name   = var.labname
  public_key = file("~/.ssh/id_rsa.pub")

  tags = var.lab_tag
}

resource "aws_security_group" "firewall" {
  name = var.labname

  vpc_id = module.network.vpc_id

  dynamic "ingress" {
    for_each = var.default_ingress
    content {
      description = ingress.value["description"]
      from_port   = ingress.key
      to_port     = ingress.key
      protocol    = "tcp"
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

data "aws_ami" "ubuntu-bionic" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"

  name           = var.labname
  instance_count = 2

  ami                    = data.aws_ami.ubuntu-bionic.id
  instance_type          = var.ec2_instance_type
  key_name               = module.key_pair.key_pair_key_name
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.firewall.id]
  subnet_id              = module.network.public_subnets[0]

  tags = var.lab_tag
}

output "public_ips" {
  value = module.ec2.public_ip[*]
}