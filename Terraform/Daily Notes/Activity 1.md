# Activity 1 - Creating a VPC with 4 subnets

1. Create Resource Group (for Azure)
2. Create Virtual Network
3. Create Subnets

## For Azure
* Create a folder `mkdir activity1`
* `cd activity1`
* Create another folder `mkdir forAzure`.
* `cd forAzure`
* Open the folder in desired ide (preferred vscode)

#### Phase 0 - Initial Setup
* create `terraform.tf` - for required providers
```terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.14.0"
    }
  }
  required_version = ">= 1.10.0"
}
``` 
* Create `providers.tf` - for information about cloud providers
```
provider "azurerm" {
  features {

  }
  subscription_id = "your azure subscription id"
}
```
* Create `.tflint.hcl` and paste
```
plugin "azurerm" {
    enabled = true
    version = "0.27.0"
    source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}
```
* Now Create 3 new files
    * `variables.tf` - for information about variables type
    * `data.tfvars` - for actual variable data
    * `main.tf` - for creating
#### Phase 1 - Creating Resource Group
* [Refer Here for Azure Resource Group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group).
* Open `variables.tf` and write
```
variable "resourceGroup" {
  type = object({
    name     = string
    location = string
  })
}
```
* Open `data.tfvars` and write
```
resourceGroup = {
  name     = "myResourceGroup"
  location = "eastus"
}
```
* Open `main.tf` and write
```
resource "azurerm_resource_group" "myResourceGroup" {
  name     = var.resourceGroup.name
  location = var.resourceGroup.location
}
```

#### Phase 2 - Creating Virtual Network
* [Refer Here for Azure Virtual Network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network).
* In `variables.tf`
```
variable "virtualNetwork" {
  type = object({
    name          = string
    address_space = list(string)
  })
}
```
* In `data.tfvars`
```
virtualNetwork = {
  name          = "myVirtualNetwork"
  address_space = ["10.0.1.0/24", "10.0.2.0/24",
  "10.0.3.0/24", "10.0.4.0/24"]
}
```
* In `main.tf`
```
resource "azurerm_virtual_network" "myVirtualNetwork" {
  name                = var.virtualNetwork.name
  resource_group_name = azurerm_resource_group.myResourceGroup.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myResourceGroup.location
  depends_on          = [azurerm_resource_group.myResourceGroup]
}
```

#### Phase 3 - Creating Subnets
* [Refer Here for Azure Subnets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet).
* In `variables.tf`
```
variable "subnets_prefixs" {
  type = object({
    names         = list(string)
    address_space = list(string)
  })
}
```
* In `data.tfvars`
```
subnets_prefixs = {
  names         = ["sub1", "sub2", "sub3", "sub4"]
  address_space = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}
```
* In `main.tf`
```
resource "azurerm_subnet" "mySubnets" {
  count                = length(var.subnets_prefixs.address_space)
  name                 = var.subnets_prefixs.names[count.index]
  resource_group_name  = azurerm_resource_group.myResourceGroup.name
  virtual_network_name = azurerm_virtual_network.myVirtualNetwork.name
  address_prefixes     = [element(var.subnets_prefixs.address_space, count.index)]
}
```
#### Phase 4 - Executing
* Open terminal and run following
    * `terraform init`
    * `terraform fmt`
    * `terraform validate`
    * `tflint`
    * `terraform plan -var-file="data.tfvars"`
    * `terraform apply -var-file="data.tfvars"`
    * `terraform destroy -var-file="data.tfvars"` - use for destroying only.


## For AWS
* Create a folder `mkdir activity1`
* `cd activity1`
* Create another folder `mkdir forAWS`
* `cd forAWS`
* Open the folder in desired ide (preferred vscode)

#### Phase 0 - Initial Setup
* create `terraform.tf` - for required providers
```terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
  required_version = ">= 1.10.0"
}
``` 
* Create `providers.tf` - for information about cloud providers
```
provider "aws" {
    region = "ap-south-1"
}
```
* Create `.tflint.hcl` and paste
```
plugin "aws" {
    enabled = true
    version = "0.37.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
```
* Now Create 3 new files
    * `variables.tf` - for information about variables type
    * `data.tfvars` - for actual variable data
    * `main.tf` - for creating

#### Phase 1 - Creating VPC
* [Refer Here for AWS VPC Network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc).
* In `variables.tf`
```
variable "vpc_network" {
  type = object({
    cidr = string
    Name = string
  })
}
```
* In `data.tfvars`
```
vpc_network = {
  cidr = "10.0.0.0/16"
  Name = "vpcNet"
}
```
* In `main.tf`
```
resource "aws_vpc" "network" {
  cidr_block = var.vpc_network.cidr
  tags = {
    Name = var.vpc_network.Name
  }
}
```

#### Phase 2 - Creating Subnets
* [Refer Here for AWS Subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet).
* In `variables.tf`
```
variable "subnets_info" {
  type = list(object({
    az   = string
    cidr = string
    Name = string
  }))
}
```
* In `data.tfvars`
```
subnets_info = [{
  Name = "web1"
  cidr = "10.0.0.0/24"
  az   = "ap-south-1a"
  },
  {
    Name = "web2"
    cidr = "10.0.1.0/24"
    az   = "ap-south-1b"
  },
  {
    Name = "db1"
    cidr = "10.0.2.0/24"
    az   = "ap-south-1a"
  },
  {
    Name = "db2"
    cidr = "10.0.3.0/24"
    az   = "ap-south-1b"
}]
```
* In `main.tf`
```
resource "aws_subnet" "subnets" {
  count             = length(var.subnets_info)
  vpc_id            = aws_vpc.network.id
  availability_zone = var.subnets_info[count.index].az
  cidr_block        = var.subnets_info[count.index].cidr
  depends_on        = [aws_vpc.network]
  tags = {
    Name = var.subnets_info[count.index].Name
  }
}
```
#### Phase 3 - Executing
* Open terminal and run following
    * `terraform init`
    * `terraform fmt`
    * `terraform validate`
    * `tflint`
    * `terraform plan -var-file="data.tfvars"`
    * `terraform apply -var-file="data.tfvars"`
    * `terraform destroy -var-file="data.tfvars"` - use for destroying only.