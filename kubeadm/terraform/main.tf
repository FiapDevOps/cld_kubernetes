# https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/examples/http/main.tf
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group


# Configurando o cloud provider
provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


resource "tls_private_key" "lab_resource_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "lab_key" {
  key_name   = var.key_name
  public_key = tls_private_key.lab_resource_key.public_key_openssh
}

data "aws_vpc" "def_vpc" {
  default = "true"
}

data "aws_security_group" "cloud9" {
  vpc_id = data.aws_vpc.def_vpc.id

  filter {
    name   = "group-name"
    values = ["*cloud9*"]
  }
}

resource "aws_security_group" "kubeadm_sg" {

  name        = "kubernetes"
  description = "Kubernetes access to deploy cluster using kubeadm"
  vpc_id      = data.aws_vpc.def_vpc.id
  
  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    self = true
  }

  ingress {
    description      = "Full access from cloud9 SG"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups  = [data.aws_security_group.cloud9.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "kubernetes"
    terraform = "true"
    env = "kubeadm"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "kubernetes_workers" {
    ami                         = data.aws_ami.ubuntu.id
    instance_type               = "t3a.medium"
    associate_public_ip_address = true    
    user_data                   = "${file("templates/kubeadm.yaml")}"
    key_name                    = aws_key_pair.lab_key.key_name
    vpc_security_group_ids      = ["${aws_security_group.kubeadm_sg.id}"]
    depends_on                  = [aws_security_group.kubeadm_sg]
    count                       = "2"

    tags = {
        terraform = "true"
        env       = "kubeadm"
        Name      = "worker"
    }
}

resource "aws_instance" "kubernetes_controlplane" {
    ami                         = data.aws_ami.ubuntu.id
    instance_type               = "t3a.medium"
    associate_public_ip_address = true    
    user_data                   = "${file("templates/kubeadm.yaml")}"
    key_name                    = aws_key_pair.lab_key.key_name
    vpc_security_group_ids      = ["${aws_security_group.kubeadm_sg.id}"]
    depends_on                  = [aws_security_group.kubeadm_sg]
    
    tags = {
        terraform = "true"
        env       = "kubeadm"
        Name      = "controlplane"
    }
}
