# Variable Block for vpc_network
variable "vpc_network" {
  type = object({
    cidr = string
    Name = string
  })
}

# Variable block for subnets
variable "subnets_info" {
  type = list(object({
    az   = string
    cidr = string
    Name = string
  }))
}