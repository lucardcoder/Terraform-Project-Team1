## VPC

Below module will create a VPC along with 3 Public and 3 Private subnets,Public and a Private route tables, an Internet Gateway to Public Subnets and  NAT gateways to each Private Subnets.
```
module "vpc-team1" {
  source  = "lucardcoder/vpc-team1/aws"
  version = "1.0.0"


  region          = var.region
  cidr_block      = var.cidr_block
  public_subnet1  = var.public_subnet1
  public_subnet2  = var.public_subnet2
  public_subnet3  = var.public_subnet3
  private_subnet1 = var.private_subnet1
  private_subnet2 = var.private_subnet2
  private_subnet3 = var.private_subnet3

  enable_nat_gateway = var.enable_nat_gateway

  tags = var.tags

}

```

