# Activity 2 - Complete Network

1. Create Resource Group (For Azure).
2. Create VPC.
3. Create internet gateway.
4. Create Private Route Table.
5. Create Public Route Table.
6. Add route in public route table to Internet Gateway.
7. Create subnets for public and associate with public route table.
8. Create subnets for private and associate with private route table

## For Azure
* Create a folder `mkdir activity2`
* `cd activity2`
* Create another folder `mkdir forAzure`.
* `cd forAzure`
* Open the folder in desired ide (preferred vscode)

#### Phase 0 - Initial Setup

#### Phase 1

#### Phase 2


## For AWS
* Create a folder `mkdir activity2`
* `cd activity2`
* Create another folder `mkdir forAWS`.
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
* Open `variables.tf`
```
variable "myVPC" {
  type = object({
    cidr = string
    Name = string
  })
}
```
* Open `data.tfvars`
```
myVPC = {
  cidr = "10.10.0.0/16"
  Name = "My VPC"
}
```
* Open `main.tf`
```
resource "aws_vpc" "myNetwork" {
  cidr_block = var.myVPC.cidr
  tags = {
    Name = var.myVPC.Name
  }
}
```

#### Phase 2 - Creating Gateway
* [Refer Here for AWS Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)
* Open `variables.tf`
```
variable "myGateway" {
  type = object({
    Name = string
  })
}
```
* Open `data.tfvars`
```
myGateway = {
  Name = "My Gateway"
}
```
* Open `main.tf`
```
resource "aws_internet_gateway" "myGateway" {
  vpc_id = aws_vpc.myNetwork.id
  tags = {
    Name = "${var.myGateway.Name}-igw"
  }
  depends_on = [aws_vpc.myNetwork]
}
```

#### Additional One
* [Refer here for Documentation of locals](https://developer.hashicorp.com/terraform/language/values/locals)
* Create `locals.tf`
```
locals {
  anywhere              = "0.0.0.0/0"
  public_subnets_count  = length(var.publicSubnets)
  private_subnets_count = length(var.privateSubnets)
}
```

#### Phase 3 - Private Route Table
* [Refer Route Tables](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)
* Open `variables.tf`
```
variable "private_rt" {
  type = object({
    Name = string
  })
}
```
* Open `data.tfvars`
```
private_rt = {
  Name = "Private Route Table"
}
```
* Open `main.tf`
```
resource "aws_route_table" "private" {
  count  = local.private_subnets_count != 0 ? 1 : 0
  vpc_id = aws_vpc.myNetwork.id
  tags = {
    Name = "${var.private_rt.Name}"
  }
  depends_on = [aws_vpc.myNetwork, aws_internet_gateway.myGateway]
}
```

#### Phase 4 - Public Route Table
* [Route Tables](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)
* Open `variables.tf`
```
variable "public_rt" {
  type = object({
    cidr = string
    Name = string
  })
}
```
* Open `data.tfvars`
```
public_rt = {
  Name = "Public Route Table"
  cidr = "0.0.0.0/0"
}
```
* Open `main.tf`
```
resource "aws_route_table" "public" {
  count  = local.public_subnets_count != 0 ? 1 : 0
  vpc_id = aws_vpc.myNetwork.id
  route {
    cidr_block = local.anywhere
    gateway_id = aws_internet_gateway.myGateway.id
  }
  tags = {
    Name = "${var.public_rt.Name}"
  }
  depends_on = [aws_vpc.myNetwork, aws_internet_gateway.myGateway]
}
```

#### Phase 5 - Private Subnets
* [Subnets Reference](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)
* Open `variables.tf`
```
variable "privateSubnets" {
  type = list(object({
    Name = string
    cidr = string
    az   = string
  }))
}
```
* Open `data.tfvars`
```
privateSubnets = [{
  Name = "db-1"
  cidr = "10.10.2.0/24"
  az   = "ap-south-1a"
  }, {
  Name = "db-2"
  cidr = "10.10.3.0/24"
  az   = "ap-south-1b"
}]
```
* Open `main.tf`
```
resource "aws_subnet" "private" {
  count             = local.private_subnets_count
  vpc_id            = aws_vpc.myNetwork.id
  availability_zone = var.privateSubnets[count.index].az
  cidr_block        = var.privateSubnets[count.index].cidr
  tags = {
    Name = var.privateSubnets[count.index].Name
  }
  depends_on = [aws_vpc.myNetwork]
}
```

#### Phase 6 - Private subnets Association to Private Route Table
* [Route Table Association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)
* Open `main.tf`
```
resource "aws_route_table_association" "private_subnets_association" {
  count          = local.private_subnets_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}
```

#### Phase 7 - Public Subnets
* [Subnets Reference](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)
* Open `variables.tf`
```
variable "publicSubnets" {
  type = list(object({
    Name = string
    cidr = string
    az   = string
  }))
}
```
* Open `data.tfvars`
```
publicSubnets = [{
  Name = "web-1"
  cidr = "10.10.0.0/24"
  az   = "ap-south-1a"
  }, {
  Name = "web-2"
  cidr = "10.10.1.0/24"
  az   = "ap-south-1b"
}]
```
* Open `main.tf`
```
resource "aws_subnet" "public" {
  count             = local.public_subnets_count
  vpc_id            = aws_vpc.myNetwork.id
  availability_zone = var.publicSubnets[count.index].az
  cidr_block        = var.publicSubnets[count.index].cidr
  tags = {
    Name = var.publicSubnets[count.index].Name
  }
  depends_on = [aws_vpc.myNetwork]
}
```

#### Phase 8- Public Subnets association to Public Route Table
* [Route Table Association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)
* Open `main.tf`
```
resource "aws_route_table_association" "public_subnets_association" {
  count          = local.public_subnets_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
  depends_on     = [aws_route_table.public, aws_internet_gateway.myGateway]
}
```

#### Phase Execution
* Open terminal and run following
    * `terraform init`
    * `terraform fmt`
    * `terraform validate`
    * `tflint`
    * `terraform plan -var-file="data.tfvars"`
    * `terraform apply -var-file="data.tfvars"`
    * `terraform destroy -var-file="data.tfvars"` - use for destroying only.