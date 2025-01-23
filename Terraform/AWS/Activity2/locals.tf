locals {
  anywhere              = "0.0.0.0/0"
  public_subnets_count  = length(var.publicSubnets)
  private_subnets_count = length(var.privateSubnets)
}