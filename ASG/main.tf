
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





data "aws_ami" "amazon-linux-2" {
  most_recent = true


  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}







resource "aws_security_group" "ec2-sg" {
  name        = "Project-Team1"
  description = "EC2 Instance Security Group"
  vpc_id      = data.terraform_remote_state.backend.outputs.vpc_id


  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }



  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = var.tags
}


data "template_file" "user_data" {
  template = file("user_data.sh")
  vars = {
    db_username      = var.database_user
    db_user_password = data.aws_ssm_parameter.foo.value ## retreive from random_string resource in main.tf in RDS folder.
    db_name          = var.database_name
    db_RDS           = data.aws_rds_cluster.wordpress_db_cluster.endpoint
    efs_dns_name     = data.aws_efs_file_system.efs.dns_name
  }
}


data "aws_ssm_parameter" "foo" {
  name = "wordpress"
}


data "aws_efs_file_system" "efs" {
}


data "aws_rds_cluster" "wordpress_db_cluster" {
  cluster_identifier = "wordpress-cluster"
}







#Create ASG

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.3"
  # Autoscaling group
  name                      = "Project-asg"
  min_size                  = 1
  max_size                  = 99
  desired_capacity          = 3
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier = [
    data.terraform_remote_state.backend.outputs.private_subnet1,
    data.terraform_remote_state.backend.outputs.private_subnet2,
    data.terraform_remote_state.backend.outputs.private_subnet3
  ]
  depends_on = [module.alb]





  # Launch template
  launch_template_name        = "Project-asg"
  launch_template_description = "Launch template example"
  update_default_version      = true
  image_id                    = data.aws_ami.amazon-linux-2.id
  instance_type               = "t3.micro"
  ebs_optimized               = false
  enable_monitoring           = false
  user_data                   = base64encode(data.template_file.user_data.rendered)
  target_group_arns           = module.alb.target_group_arns
  security_groups = [
    aws_security_group.ec2-sg.id
  ]
  tags = var.tags
}









#Create ALB

module "alb" {
  source                           = "terraform-aws-modules/alb/aws"
  version                          = "~> 8.0"
  name                             = "my-alb"
  load_balancer_type               = "application"
  enable_cross_zone_load_balancing = true
  vpc_id                           = data.terraform_remote_state.backend.outputs.vpc_id
  subnets = [
    data.terraform_remote_state.backend.outputs.public_subnet1,
    data.terraform_remote_state.backend.outputs.public_subnet2,
    data.terraform_remote_state.backend.outputs.public_subnet3
  ]


  security_groups = [
    aws_security_group.alb-sg.id
  ]

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
  tags = var.tags
}


# ALB Security Group
resource "aws_security_group" "alb-sg" {
  description = "ALB Security Group"
  vpc_id      = data.terraform_remote_state.backend.outputs.vpc_id


  # Allow HTTP/HTTPS from ALL
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP/HTTPS from ALL
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow All Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}






data "aws_route53_zone" "my_zone" {
  name         = var.domain_name
  private_zone = false
}



resource "aws_route53_record" "alias_route53_record" {
  zone_id = data.aws_route53_zone.my_zone.zone_id
  name    = "wordpress.${var.domain_name}" # Replace with your name/domain/subdomain
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}


