provider "aws" {
  profile    = "lg"
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

data "terraform_remote_state" "keypair_dev" {
  backend = "local"
  config = {
    path = "../../dev/keypair/terraform.tfstate"
  }
}


locals {
  region            = var.lookup-region_abbr["${var.region}"]
  ami               = lookup(var.aws_amis, var.region)
  instance ={
    default_ec2_type = "m5.large"
    default_ebs_size = 100
    bastion_ec2_type = "t3.micro"
    bastion_ebs_size = 8
  }
}




#################################################################################
## EC2                                                                         ##
#################################################################################
module "jenkins" {
  source = "../../terraform/module/ec2"

  name                    = "${var.project}-${var.environment}-${local.region}-jenkins"
  ami                     = local.ami[0]
  instance_type           = local.instance.default_ec2_type
  key_name                = data.terraform_remote_state.keypair.outputs.keypair_name
  monitoring              = false

  vpc_security_group_ids  = ["${data.terraform_remote_state.security.outputs.security_ids.jenkins}"]
  subnet_id               = element(data.terraform_remote_state.vpc.outputs.pri_subnet_ids, 1)
  availability_zone       = element(data.terraform_remote_state.vpc.outputs.vpc_azs, 1)

  root_block_device = [
        {
          encrypted   = true
          volume_type = "gp3"
          throughput  = 200
          volume_size = local.instance.default_ebs_size
        }
  ]
   tags = {
    Project             = "${var.project}"
  }
}

module "gitlab" {
  source = "../../terraform/module/ec2"

  name                    = "${var.project}-${var.environment}-${local.region}-gitlab"
  ami                     = local.ami[0]
  instance_type           = local.instance.default_ec2_type
  key_name                = data.terraform_remote_state.keypair.outputs.keypair_name
  monitoring              = false

  vpc_security_group_ids  = ["${data.terraform_remote_state.security.outputs.security_ids.gitlab}"]
  subnet_id               = element(data.terraform_remote_state.vpc.outputs.pri_subnet_ids, 1)
  availability_zone       = element(data.terraform_remote_state.vpc.outputs.vpc_azs, 1)

  root_block_device = [
        {
          encrypted   = true
          volume_type = "gp3"
          throughput  = 200
          volume_size = local.instance.default_ebs_size
        }
  ]
   tags = {
    Project             = "${var.project}"
  }
}

module "prd_bastion" {
  source = "../../terraform/module/ec2"

  name                    = "${var.project}-${var.environment}-${local.region}-prd_bastion"
  ami                     = local.ami[0]
  instance_type           = local.instance.bastion_ec2_type
  key_name                = data.terraform_remote_state.keypair.outputs.keypair_name
  monitoring              = false

  vpc_security_group_ids  = ["${data.terraform_remote_state.security.outputs.security_ids.prd_bastion}"]
  subnet_id               = element(data.terraform_remote_state.vpc.outputs.pub_subnet_ids, 1)
  availability_zone       = element(data.terraform_remote_state.vpc.outputs.vpc_azs, 1)

  root_block_device = [
        {
          encrypted   = true
          volume_type = "gp3"
          throughput  = 200
          volume_size = local.instance.bastion_ebs_size
        }
  ]
   tags = {
    Project             = "${var.project}"
  }
}



