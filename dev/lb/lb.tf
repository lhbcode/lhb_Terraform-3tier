provider "aws" {
  profile = "lg"
  region     = var.region
}

locals {
  region            = var.lookup-region_abbr["${var.region}"]
}

data "terraform_remote_state" "ec2" {
  backend = "local"
  config = {
    path = "../ec2/terraform.tfstate"
  }
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

module "waf_alb" {
  source = "../../terraform/module/lb"

  name = "${var.project}-${var.environment}-${local.region}-waf-alb"

  load_balancer_type = "application"

  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets         = data.terraform_remote_state.vpc.outputs.pub_subnet_ids
  security_groups = ["${data.terraform_remote_state.security.outputs.security_ids.pub_alb}"]


  target_groups = [
    {
      name     = "${var.project}-${var.environment}-${local.region}-waf-tg"
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "instance"
      targets = [
        {
          target_id = "${data.terraform_remote_state.ec2.outputs.ec2_id.waf}"
          port      = 8080
        }
      ]
    },
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
   tags = {
    Project             = "${var.project}"
  }
}

module "web_alb" {
  source = "../../terraform/module/lb"

  name = "${var.project}-${var.environment}-${local.region}-web-alb"

  load_balancer_type = "application"

  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets         = slice(data.terraform_remote_state.vpc.outputs.pri_subnet_ids,0,2)
  security_groups = ["${data.terraform_remote_state.security.outputs.security_ids.pri_web_alb}"]
  internal = true


  target_groups = [
    {
      name     = "${var.project}-${var.environment}-${local.region}-web-tg"
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "instance"
      targets = [
        {
          target_id = "${data.terraform_remote_state.ec2.outputs.ec2_id.web}"
          port      = 8080
        }
      ]
    },
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
   tags = {
    Project             = "${var.project}"
  }
}




module "was_alb" {
  source = "../../terraform/module/lb"

  name = "${var.project}-${var.environment}-${local.region}-was-alb"

  load_balancer_type = "application"

  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets         = slice(data.terraform_remote_state.vpc.outputs.pri_subnet_ids,2,4)
  security_groups = ["${data.terraform_remote_state.security.outputs.security_ids.pri_was_alb}"]
  internal = true


  target_groups = [
    {
      name     = "${var.project}-${var.environment}-${local.region}-was-tg"
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "instance"
      targets = [
        {
          target_id = "${data.terraform_remote_state.ec2.outputs.ec2_id.was}"
          port      = 8080
        }
      ]
    },
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
   tags = {
    Project             = "${var.project}"
  }
}
