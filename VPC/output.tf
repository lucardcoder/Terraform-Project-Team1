

output "vpc_id" {
  value = module.vpc-team1.vpc_id
}
output "public_subnet1" {
  value = module.vpc-team1.public_subnet1
}
output "public_subnet2" {
  value = module.vpc-team1.public_subnet2
}
output "public_subnet3" {
  value = module.vpc-team1.public_subnet3
}
output "private_subnet1" {
  value = module.vpc-team1.private_subnet1
}
output "private_subnet2" {
  value = module.vpc-team1.private_subnet2
}
output "private_subnet3" {
  value = module.vpc-team1.private_subnet3
}
output "az1" {
  value = module.vpc-team1.az1
}
output "az2" {
  value = module.vpc-team1.az2
}
output "az3" {
  value = module.vpc-team1.az3
}


# output all {
#     value = terraform_remote_state.remote.outputs.*
# }
