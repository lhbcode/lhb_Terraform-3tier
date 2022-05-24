provider "aws" {
  profile = "lg"
  region     = var.region
}

locals {
   region   = var.lookup-region_abbr["${var.region}"]
   name = "${var.project}-${var.environment}-${local.region}-postgres-db"
}

data "terraform_remote_state" "security" {
  backend = "local"
  config = {
    path = "../security/terraform.tfstate"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
}

#################################################################################
## RDS postgres                                                                    #
#################################################################################

module "postgres" {
 source = "../../terraform/module/rds"

 identifier            = local.name

 engine                = "postgres"
 engine_version        = "14.1"
 family                = "postgres14"
 major_engine_version  = "14"
 instance_class        = var.dbInstanceType
 port                  = "5432"
 username              = var.dbUserName
 password              = var.dbPassword

 allocated_storage      = var.Volume
 max_allocated_storage  = 1500

 multi_az = false
 db_subnet_group_name   = data.terraform_remote_state.vpc.outputs.db_group_name
 vpc_security_group_ids = ["${data.terraform_remote_state.security.outputs.security_ids.db}"]

 backup_window                       = "17:00-18:00"
 maintenance_window                  = "sun:20:00-sun:21:00"
 backup_retention_period             = 0

 enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
 create_cloudwatch_log_group     = true
 
 deletion_protection     = false
 skip_final_snapshot     = true

create_db_option_group    = true
create_db_parameter_group = true
  tags = {
   Project    = "${var.project}"
 }

}





