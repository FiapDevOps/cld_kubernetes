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


data "aws_vpc" "main" {
  tags = {
    terraform = "true"
    env       = "lab"
  }
}

data "aws_vpc" "def_vpc" {
  default = true
}

data "aws_security_group" "cloud9" {
  vpc_id = data.aws_vpc.def_vpc.id

  filter {
    name   = "group-name"
    values = ["*cloud9*"]
  }
}

# Construindo um security group para a instância de control plane

resource "aws_security_group" "kubernetes_external_access" {

  name        = "kubernetes_external_access"
  description = "Kubernetes access from Cloud9"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description      = "Kubernetes API server"
    from_port        = 6443
    to_port          = 6443
    protocol         = "tcp"
    security_groups  = [data.aws_security_group.cloud9.id]
  }

  ingress {
    description      = "Kubelet API"
    from_port        = 10250
    to_port          = 10250
    protocol         = "tcp"
    security_groups = [data.aws_security_group.cloud9.id]
  }

  ingress {
    description      = "etcd server client API"
    from_port        = 2379
    to_port          = 2380
    protocol         = "tcp"
    security_groups = [data.aws_security_group.cloud9.id]
  }

  ingress {
    description      = "NodePort Services"
    from_port        = 30000
    to_port          = 32767
    protocol         = "tcp"
    security_groups = [data.aws_security_group.cloud9.id]
  }
  
  ingress {
    description      = "Instance SSH Access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [data.aws_security_group.cloud9.id]
  }
  
  ingress {
    description      = "Instance ICMP Access"
    from_port = -1
    to_port = -1
    protocol = "icmp"
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
    Name = "kubernetes_access"
    terraform = "true"
    env = "lab"
    tier = "private"
  }
}

# Construindo um security group para os workers nodes

resource "aws_security_group" "kubernetes" {

  name        = "kubernetes"
  description = "Kubernetes access between instances"
  vpc_id      = data.aws_vpc.main.id
  
  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    self = true
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
    env = "lab"
    tier = "private"
  }
}

# Deploy Instances

data "aws_security_groups" "selected" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  
  tags = {
    terraform = "true" 
    env = "lab"
  }
}

data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.main.id

  filter {
    name   = "tag:Name"
    values = ["*private*"] # insert values here
  }

  tags = {
    terraform = "true"
    env = "lab"
  }
}

resource random_id index {
  byte_length = 2
}

locals {
  subnet_ids_list = tolist(data.aws_subnet_ids.selected.ids)
  subnet_ids_random_index = random_id.index.dec % length(data.aws_subnet_ids.selected.ids)
  instance_subnet_id = local.subnet_ids_list[local.subnet_ids_random_index]
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "controlplane" {
    ami                         = data.aws_ami.ubuntu.id
    instance_type               = "t3a.medium"
    associate_public_ip_address = false    
    user_data                   = "${file("templates/kubetools.yaml")}"
    vpc_security_group_ids      = tolist(data.aws_security_groups.selected.ids)
    key_name                    = "vockey"
    subnet_id                   = local.instance_subnet_id
    tags = {
        terraform = "true"
        env       = "lab"
        tier      = "private"
    }
}

resource "aws_instance" "workers" {
  for_each                      = data.aws_subnet_ids.selected.ids
    ami                         = data.aws_ami.ubuntu.id
    instance_type               = "t3.medium"
    associate_public_ip_address = false    
    user_data                   = "${file("templates/kubetools.yaml")}"
    vpc_security_group_ids      = tolist(data.aws_security_groups.selected.ids)
    key_name                    = "vockey"

    subnet_id                   = each.value
    tags = {
        terraform = "true"
        env       = "lab"
        tier      = "private"
    }
}