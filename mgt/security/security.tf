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

module "security_group_jenkins" {
  source = "../../terraform/module/security"

  name        = "${var.project}-${var.environment}-jenkins-sg"
  description = "Security group for jenkins usage with EC2 instance"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks = ["${data.terraform_remote_state.vpc.outputs.vpc_cidr}"]
  ingress_rules       = ["http-80-tcp","https-443-tcp"]
   egress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
      cidr_blocks = "0.0.0.0/0"
    },

  ]
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.security_group_gitlab.security_group_id
      description = "ingress gitlab all"
    },
     {
      rule                     = "ssh-tcp"
      source_security_group_id = module.security_group_prd_bastion.security_group_id
      description = "ingress prd bastion ssh"
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 2
  
  computed_egress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.security_group_gitlab.security_group_id
      description = "egress gitlab all"
    },
  ]
  number_of_computed_egress_with_source_security_group_id = 1
  
  tags = {
    Project    = "${var.project}"

  }
}

module "security_group_gitlab" {
  source = "../../terraform/module/security"

  name        = "${var.project}-${var.environment}-gitlab-sg"
  description = "Security group for gitlab usage with EC2 instance"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks = ["${data.terraform_remote_state.vpc.outputs.vpc_cidr}"]
  ingress_rules       = ["http-80-tcp","https-443-tcp"]
  egress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
      cidr_blocks = "0.0.0.0/0"
    },

  ]
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.security_group_jenkins.security_group_id
      description = "ingress jenkins all"
    },
      {
      rule                     = "ssh-tcp"
      source_security_group_id = module.security_group_prd_bastion.security_group_id
      description = "ingress prd bastion ssh"
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 2

  computed_egress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.security_group_jenkins.security_group_id
      description = "egress jenkins all"
    },
  ]
  number_of_computed_egress_with_source_security_group_id = 1


  #  ingress_with_cidr_blocks = [
  #   {
  #     from_port   = 30000
  #     to_port     = 32767
  #     protocol    = "tcp"
  #     description = "NodePort"
  #     cidr_blocks = "0.0.0.0/0"
  #   },
  # ]
  
  tags = {
    Project    = "${var.project}"

  }
}

module "security_group_prd_bastion" {
  source = "../../terraform/module/security"

  name        = "${var.project}-${var.environment}-prd-bastion-sg"
  description = "Security group for prd_bastion usage with EC2 instance"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp" ]
  egress_cidr_blocks = ["10.20.0.0/16"]
  egress_rules        = ["ssh-tcp"]
    egress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
      cidr_blocks = "0.0.0.0/0"
    },

  ]
  
  tags = {
    Project    = "${var.project}"

  }
}

module "security_group_dev_bastion" {
  source = "../../terraform/module/security"

  name        = "${var.project}-${var.environment}-dev-bastion-sg"
  description = "Security group for dev_bastion usage with EC2 instance"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp" ]
  egress_cidr_blocks = ["10.10.0.0/16"]
  egress_rules        = ["ssh-tcp"]
  egress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
      cidr_blocks = "0.0.0.0/0"
    },

  ]
  tags = {
    Project    = "${var.project}"

  }
}