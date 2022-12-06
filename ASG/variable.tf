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


variable "database_name" {
  type        = string
  default     = ""
  description = "Please provide DB name"
}
variable "database_user" {
  type        = string
  default     = ""
  description = "Please provide DB username"
}

variable "domain_name" {
  description = "Please provide a domain name"
  type        = string
}