variable "aws_region" {
  type        = string
  description = "Region"
  default     = "ap-south-1"
}

variable "myVPC" {
  type = object({
    cidr = string
    Name = string
  })
}

# Gateway
variable "myGateway" {
  type = object({
    Name = string
  })
}

# Private Route Table
variable "private_rt" {
  type = object({
    Name = string
  })
}

# Public Route Table
variable "public_rt" {
  type = object({
    cidr = string
    Name = string
  })
}

# Private Subnets
variable "privateSubnets" {
  type = list(object({
    Name = string
    cidr = string
    az   = string
  }))
}

# Public Subnets
variable "publicSubnets" {
  type = list(object({
    Name = string
    cidr = string
    az   = string
  }))
}

# Security Group
variable "network_sg" {
  type = object({
    name        = optional(string, "web_sg")
    description = optional(string, "Security group for web")
    inbound_rules = list(object({
      protocol = optional(string, "tcp")
      cidr     = optional(string, "0.0.0.0/0")
      to       = number
      from     = number
    }))
  })
}

# Key Pair
variable "key_info" {
  type = object({
    name = string
    public_key_path = optional(string, "~/.ssh/id_rsa_pub")
    private_key_path = optional(string, "~/.ssh/id_rsa")
  })
}
