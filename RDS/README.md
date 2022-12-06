## AWS Aurora RDS CLuster
Database hosted inside private subnets to ensure high availability.Security group inbound rules only allow port 3306 for the web tier.Below code is used to install RDS cluster along with 1 writer, 3 reader clusters. Database login information embedded inside the userdata script. Database password is created using random provider and saved inside AWS paramater store.

```
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
```
