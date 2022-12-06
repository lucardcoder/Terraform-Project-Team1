# output "vpc_id" {
#   value = data.terraform_remote_state.backend.outputs.vpc_id
# }


# data "aws_efs_file_system" "efs" {}

# locals {
#   dns_name = data.aws_efs_file_system.efs.dns_name
# }


# output "efs_dns_name" {
#   value = data.aws_efs_file_system.efs.dns_name
# }


# data aws_ssm_parameter.dbpass{}

# locals {
#   random_result = data.aws_ssm_parameter.dbpass.value
# }

# output "random_string"{
# value = data.aws_ssm_parameter.dbpass.value
# }

# data aws_rds_cluster.wordpress_db_cluster{}

# locals {
#   db_endpoint = data.aws_rds_cluster.wordpress_db_cluster.endpoint
# }

# output "RDS_Endpoint"{
# value = data.aws_rds_cluster.wordpress_db_cluster.endpoint
# }


# data "random_string" "rds_password" {
#   length  = 16
#   special = false
# }

# data "aws_ssm_parameter" "dbpass" {
#   name  = var.database_name
#   type  = "SecureString"
#   value = random_string.rds_password.result
# }


# locals {
#   random_result = data.random_string.rds_password.result
# }

# output "random_string"{
# value = data.random_string.rds_password.result
# }

# data aws_rds_cluster.wordpress_db_cluster{
#   cluster_identifier = "wordpress-cluster"
#   endpoint = 
# }

# output all {
#     value = data.terraform_remote_state.backend.outputs.*
# }

# module EFS {
#     source = "../EFS"
# }

# output "dns_name"{
#     value = module.EFS.dns_name
# }

output "all" {
  value = data.terraform_remote_state.backend.outputs.*
}



output "INFO" {
  value = "AWS Resources and Wordpress have been provisioned. Go to http://wordpress.${var.domain_name}"
}

