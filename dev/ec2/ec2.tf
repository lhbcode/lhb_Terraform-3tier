provider "aws" {
  profile = "lg"
  region     = var.region
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "security" {
  backend = "local"
  config = {
    path = "../security/terraform.tfstate"
  }
}

data "terraform_remote_state" "keypair" {
  backend = "local"
  config = {
    path = "../keypair/terraform.tfstate"
  }
}


locals {
  region            = var.lookup-region_abbr["${var.region}"]
  ami               = lookup(var.aws_amis, var.region)
  instance_type     = "m5.large" #bastion instance type
}




#################################################################################
## EC2                                                                         ##
#################################################################################
# for master
module "ec2_waf" {
  source = "../../terraform/module/ec2"

  name                    = "${var.project}-${var.environment}-${local.region}-waf"
  ami                     = local.ami[0]
  instance_type           = local.instance_type
  key_name                = data.terraform_remote_state.keypair.outputs.keypair_name
  monitoring              = false

  vpc_security_group_ids  = ["${data.terraform_remote_state.security.outputs.security_ids.waf}"]
  subnet_id               = element(data.terraform_remote_state.vpc.outputs.pub_subnet_ids, 1)
  availability_zone       = element(data.terraform_remote_state.vpc.outputs.vpc_azs, 1)

  root_block_device = [
        {
          encrypted   = true
          volume_type = "gp3"
          throughput  = 200
          volume_size = 100
        }
  ]
   tags = {
    Project             = "${var.project}"
  }
}

#for web
module "ec2_web" {
  source = "../../terraform/module/ec2"

  name                    = "${var.project}-${var.environment}-${local.region}-web"
  ami                     = local.ami[0]
  instance_type           = local.instance_type
  key_name                = data.terraform_remote_state.keypair.outputs.keypair_name
  monitoring              = false

  vpc_security_group_ids  = ["${data.terraform_remote_state.security.outputs.security_ids.web}"]
  subnet_id               = element(data.terraform_remote_state.vpc.outputs.pri_subnet_ids, 1)
  availability_zone       = element(data.terraform_remote_state.vpc.outputs.vpc_azs, 1)

  root_block_device = [
        {
          encrypted   = true
          volume_type = "gp3"
          throughput  = 200
          volume_size = 100
        }
  ]
   tags = {
    Project             = "${var.project}"
  }
}

# for was
module "ec2_was" {
  source = "../../terraform/module/ec2"

  name                    = "${var.project}-${var.environment}-${local.region}-was"
  ami                     = local.ami[0]
  instance_type           = local.instance_type
  key_name                = data.terraform_remote_state.keypair.outputs.keypair_name
  monitoring              = false

  vpc_security_group_ids  = ["${data.terraform_remote_state.security.outputs.security_ids.was}"]
  subnet_id               = element(data.terraform_remote_state.vpc.outputs.pri_subnet_ids, 3)
  availability_zone       = element(data.terraform_remote_state.vpc.outputs.vpc_azs, 1)

  root_block_device = [
        {
          encrypted   = true
          volume_type = "gp3"
          throughput  = 200
          volume_size = 100
        }
  ]
   tags = {
    Project             = "${var.project}"
  }
}
