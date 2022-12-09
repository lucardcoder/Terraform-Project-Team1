#region = "us-east-1"    # please declare as environment variables. ex: ( export TF_VAR_region=us-east-1)

tags = {
  Name = "Terraform-project"
  Team = "Team-1"
}


#Cluster Variables
engine              = "aurora-mysql"
engine_version      = "5.7.mysql_aurora.2.10.2"
instance_class      = "db.t2.small"
database_name       = "wordpress"
master_username     = "dbadmin"
number_of_instances = 1

# domain_name = "gokalpkocer.com" ### Your domain name. please declare as environment variables. ex ( export TF_VAR_domain_name=domain.com )
