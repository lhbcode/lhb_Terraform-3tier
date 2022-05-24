
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

data "terraform_remote_state" "security_mgmt" {
  backend = "local"
  config = {
    path = "../../mgt/security/terraform.tfstate"
  }
}


module "security_group_pub_alb" {
  source = "../../terraform/module/security"

  name        = "${var.project}-${var.environment}-waf-alb-sg"
  description = "Security group for pub_alb usage with EC2 instance"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp","https-443-tcp"]
    computed_egress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.security_group_waf.security_group_id
      description = "egress waf"
    },
  ]
  number_of_computed_egress_with_source_security_group_id = 1
  
  tags = {
    Project    = "${var.project}"

  }
}

module "security_group_waf" {
  source = "../../terraform/module/security"

  name        = "${var.project}-${var.environment}-waf-sg"
  description = "Security group for waf usage with EC2 instance"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
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
      source_security_group_id = module.security_group_pub_alb.security_group_id
      description = "access waf alb"
    },
     {
      rule                     = "ssh-tcp"
      source_security_group_id = data.terraform_remote_state.security_mgmt.outputs.security_ids.dev_bastion
      description = "access dev bastion"
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 2


  computed_egress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.security_group_pri_web_alb.security_group_id
      description = "out web"
    },
     {
      rule                     = "all-all"
      source_security_group_id = module.security_group_web.security_group_id
      description = "out web"
    },
  ]
  number_of_computed_egress_with_source_security_group_id = 2


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

module "security_group_pri_web_alb" {
  source = "../../terraform/module/security"

  name        = "${var.project}-${var.environment}-web-alb-sg"
  description = "Security group for pri_alb usage with EC2 instance"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.security_group_waf.security_group_id
      description = "access waf"
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  computed_egress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.security_group_web.security_group_id
      description = "egress web"
    },
  ]
  number_of_computed_egress_with_source_security_group_id = 1

  tags = {
    Project    = "${var.project}"

  }
}

module "security_group_web" {
  source = "../../terraform/module/security"

  name        = "${var.project}-${var.environment}-web-sg"
  description = "Security group for pri_web usage with EC2 instance"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
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
      source_security_group_id = module.security_group_pri_web_alb.security_group_id
      description = "access waf alb"
    },
     {
      rule                     = "ssh-tcp"
      source_security_group_id = data.terraform_remote_state.security_mgmt.outputs.security_ids.dev_bastion
      description = "access dev bastion"
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 2

  computed_egress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.security_group_pri_was_alb.security_group_id
      description = "egress web"
    },
  ]
  number_of_computed_egress_with_source_security_group_id = 1

  tags = {
    Project    = "${var.project}"

  }
}

module "security_group_pri_was_alb" {
  source = "../../terraform/module/security"

  name        = "${var.project}-${var.environment}-was-alb-sg"
  description = "Security group for was_alb usage with EC2 instance"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.security_group_web.security_group_id
      description = "access waf"
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  computed_egress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.security_group_was.security_group_id
      description = "egress web"
    },
  ]
  number_of_computed_egress_with_source_security_group_id = 1

  tags = {
    Project    = "${var.project}"

  }
}

module "security_group_was" {
  source = "../../terraform/module/security"

  name        = "${var.project}-${var.environment}-was-sg"
  description = "Security group for was usage with EC2 instance"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
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
      source_security_group_id = module.security_group_pri_was_alb.security_group_id
      description = "access was alb"
    },
     {
      rule                     = "ssh-tcp"
      source_security_group_id = data.terraform_remote_state.security_mgmt.outputs.security_ids.dev_bastion
      description = "access dev bastion"
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 2
   computed_egress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.security_group_db.security_group_id
      description = "egress db"
    },
  ]
  number_of_computed_egress_with_source_security_group_id = 1

  tags = {
    Project    = "${var.project}"

  }
}


module "security_group_db" {
  source = "../../terraform/module/security"

  name        = "${var.project}-${var.environment}-db-sg"
  description = "Security group for db usage with EC2 instance"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.security_group_was.security_group_id
      description = "access waf"
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  tags = {
    Project    = "${var.project}"

  }
}
