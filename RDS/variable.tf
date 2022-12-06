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

variable "master_username" {
  type        = string
  default     = ""
  description = "Please provide DB name"
}


variable "number_of_instances" {
  type        = string
  default     = ""
  description = "Please provide a domain"
}

variable "cluster_engine" {
  type        = string
  default     = ""
  description = "Please provide a value"
}

variable "engine" {
  type        = string
  default     = ""
  description = "Please provide a value"
}

variable "engine_version" {
  type        = string
  default     = ""
  description = "Please provide a value"
}

variable "instance_class" {
  type        = string
  default     = ""
  description = "Please provide a value"
}

variable "domain_name" {
  description = "Please provide a domain name"
  type        = string
}