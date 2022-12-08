
data "aws_caller_identity" "current" {}


locals {
  account_id = data.aws_caller_identity.current.account_id
}


data "terraform_remote_state" "backend" {
  backend = "s3"
  config = {
    bucket = "tfstate-${local.account_id}"
    key    = "tfstate-team1/dev/VPC"
    region = "us-east-1"
  }
}


# Create EFS file system

resource "aws_efs_file_system" "efs" {
  creation_token = "my-efs"
  tags           = var.tags
}


# Create Mount targets of EFS

resource "aws_efs_mount_target" "mount1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.terraform_remote_state.backend.outputs.private_subnet1
  security_groups = [aws_security_group.efs-sg.id]
}


resource "aws_efs_mount_target" "mount2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.terraform_remote_state.backend.outputs.private_subnet2
  security_groups = [aws_security_group.efs-sg.id]
}



resource "aws_efs_mount_target" "mount3" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.terraform_remote_state.backend.outputs.private_subnet3
  security_groups = [aws_security_group.efs-sg.id]
}


# EFS Security Group

resource "aws_security_group" "efs-sg" {
  description = "EFS Project Security Group"
  vpc_id      = data.terraform_remote_state.backend.outputs.vpc_id

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [var.cidr_block]

  }

  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [var.cidr_block]
  }

  tags = var.tags
}


