

build:
		cd VPC && terraform init || terraform init -reconfigure && terraform apply -var-file dev.tfvars -auto-approve

		cd EFS && terraform init || terraform init -reconfigure && terraform apply -var-file dev.tfvars -auto-approve

		cd RDS && terraform init || terraform init -reconfigure && terraform apply -lock=false -var-file dev.tfvars -auto-approve

		cd ASG && terraform init || terraform init -reconfigure && terraform apply -lock=false -var-file dev.tfvars -auto-approve




destroy:

		cd ASG && terraform init || terraform init -reconfigure && terraform destroy -lock=false -var-file dev.tfvars -auto-approve

		cd RDS && terraform init || terraform init -reconfigure && terraform destroy -lock=false -var-file dev.tfvars -auto-approve

		cd EFS && terraform init || terraform init -reconfigure && terraform destroy -lock=false -var-file dev.tfvars -auto-approve

		cd VPC && terraform init || terraform init -reconfigure &&  terraform destroy -lock=false -var-file dev.tfvars -auto-approve


# build-ohio:

# 		cd VPC/envs/us-east-2 && terraform init && terraform apply -var-file env.tfvars -auto-approve

# 		cd ASG/envs/us-east-2 && terraform init && terraform apply -var-file env.tfvars -auto-approve


# destroy-ohio:

# 		cd VPC/envs/us-east-2 terraform destroy -var-file env.tfvars -auto-approve

# 		cd ASG/envs/us-east-2 terraform destroy -var-file env.tfvars -auto-approve



# build-all:
# 		make build && make build-ohio

# destroy-all:
# 		make destroy && make destroy-ohio