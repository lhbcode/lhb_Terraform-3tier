provider "aws" {
  profile = "lg"
  region     = var.region
}

locals {
  region            = var.lookup-region_abbr["${var.region}"]
  cidr              = "10.10.0.0/16"
  public_subnet     = ["10.10.1.0/24","10.10.2.0/24"]
  private_subnet    = ["10.10.3.0/24","10.10.4.0/24","10.10.5.0/24","10.10.6.0/24"]
  database_subnet   = ["10.10.7.0/24","10.10.8.0/24"]
}


#################################################################################
## VPC DEV                                                                     ##
#################################################################################

# for azs
data "aws_availability_zones" "azs" {
    state = "available"
}

# for vpc
module "vpc" {
  source = "../../terraform/module/vpc/"

  name = "${var.project}-${var.environment}-${local.region}-vpc"
  sub_name = "${var.project}-${var.environment}-${local.region}"
  cidr = local.cidr

  azs              = ["${data.aws_availability_zones.azs.names[1]}","${data.aws_availability_zones.azs.names[2]}"]
  public_subnets   = local.public_subnet
  private_subnets  = local.private_subnet
  database_subnets = local.database_subnet

  create_igw           = true
  enable_dhcp_options  = true
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true


   tags = {
    Project    = "${var.project}"
  }
}


