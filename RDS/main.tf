
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


#create subnet group for RDS

resource "aws_db_subnet_group" "RDS_subnet_grp" {
  subnet_ids = [
    data.terraform_remote_state.backend.outputs.private_subnet1,
    data.terraform_remote_state.backend.outputs.private_subnet2,
    data.terraform_remote_state.backend.outputs.private_subnet3,
  ]

  tags = var.tags
}



#Create security group for RDS

resource "aws_security_group" "RDS_allow_rule" {
  description = "Allow port 3306"
  vpc_id      = data.terraform_remote_state.backend.outputs.vpc_id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}


resource "random_string" "rds_password" {
  length  = 16
  special = false
}

resource "aws_ssm_parameter" "dbpass" {
  name  = var.database_name
  type  = "SecureString"
  value = random_string.rds_password.result
}


resource "aws_rds_cluster" "wordpress_db_cluster" {
  cluster_identifier   = "wordpress-cluster"
  engine               = var.engine
  engine_version       = var.engine_version
  enable_http_endpoint = true

  database_name   = var.database_name
  master_username = var.master_username
  master_password = random_string.rds_password.result

  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.RDS_subnet_grp.id
  vpc_security_group_ids  = ["${aws_security_group.RDS_allow_rule.id}"]
  backup_retention_period = 5
  storage_encrypted       = true
}

resource "aws_rds_cluster_instance" "wordpress_cluster_instance_writer" {
  apply_immediately  = true
  cluster_identifier = aws_rds_cluster.wordpress_db_cluster.id
  identifier         = "wordpress-cluster-instance-writer"
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.wordpress_db_cluster.engine
  engine_version     = aws_rds_cluster.wordpress_db_cluster.engine_version

  depends_on = [aws_rds_cluster.wordpress_db_cluster]
}

resource "aws_rds_cluster_instance" "wordpress_cluster_instance_readers" {
  count              = var.number_of_instances # 3
  apply_immediately  = true
  cluster_identifier = aws_rds_cluster.wordpress_db_cluster.id
  identifier         = "wordpress-cluster-instance-reader${format(count.index + 1)}"
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.wordpress_db_cluster.engine
  engine_version     = aws_rds_cluster.wordpress_db_cluster.engine_version

  depends_on = [aws_rds_cluster_instance.wordpress_cluster_instance_writer]
}



data "aws_route53_zone" "my_zone" {
  name         = var.domain_name
  private_zone = false
}


resource "aws_route53_record" "writer" {
  zone_id = data.aws_route53_zone.my_zone.zone_id
  name    = "writer.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_rds_cluster_instance.wordpress_cluster_instance_writer.endpoint]
}




# Use below if more than 1 readers #

resource "aws_route53_record" "readers" {
  count = var.number_of_instances

  zone_id = data.aws_route53_zone.my_zone.zone_id
  name    = "reader${count.index + 1}.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_rds_cluster_instance.wordpress_cluster_instance_readers[count.index].endpoint]
}

