variable "region" {
  description = "Please provide a region name"
  type        = string
}

variable "tags" {
  description = "Please provide a tag for resources"
  type        = map(any)
  default     = {}
}

# variable "access_key" {
#   type = "string"
# }

# variable "secret_key" {
#   type = "string"
# }


variable "cidr_block" {
  description = "Please provide CIDR block for VPC"
  type        = string
  default     = ""
}


variable "domain_name" {
  description = "Please provide a domain name"
  type        = string
}