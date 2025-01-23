variable "ntier" {
  type = object({
    cidr = string
    name = string
  })
}

variable "websg" {
  type = object({
    name        = string
    description = string
    ingress_rules = object({
      from        = number
      to          = number
      protocol    = string
      cidr        = string
      description = string
    })

    egress_rules = object({
      from        = number
      to          = number
      protocol    = string
      cidr        = string
      description = string
    })
  })
}

variable "db_sg" {
  type = object({
    name        = string
    description = string
    ingress_rules = object({
      from        = number
      to          = number
      protocol    = string
      cidr        = string
      description = string
    })
    egress_rules = object({
      from        = number
      to          = number
      protocol    = string
      cidr        = string
      description = string
    })
  })
}

# Public Subnets
variable "public_subnet" {
  type = object({
    name = string
    cidr = string
    az   = string
  })
}

# Private Subnets
variable "private_subnet" {
  type = object({
    name = string
    cidr = string
    az   = string
  })
}

# Key Pair
variable "ntier_kp" {
  type = object({
    name     = string
    key_path = optional(string, "~/.ssh/id_rsa.pub")
  })
}

# Servers Info

# Webserver
variable "web_instance_info" {
  type = object({
    name = string
    ami  = string
    az   = string
    tier = string
  })
}

# Databse Server
variable "db_instance_info" {
  type = object({
    name = string
    ami  = string
    az   = string
    tier = string
  })
}
