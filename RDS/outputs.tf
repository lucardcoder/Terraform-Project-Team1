# output "vpc_id" {
#   value = data.terraform_remote_state.backend.outputs.vpc_id
# }

# output all {
#     value = data.terraform_remote_state.remote.outputs.*
# }

output "all_outputs"{
  value = data.terraform_remote_state.backend.outputs.*
}