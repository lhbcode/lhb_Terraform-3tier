output "vpc_id" {
    value = "${module.vpc.vpc_id}"
}

output "vpc_cidr" {
    value = "${local.cidr}"
}

output "vpc_azs" {
    value = "${module.vpc.azs[*]}"
}

output "pri_subnet_ids" {
value = "${module.vpc.private_subnets[*]}"
}

output "pub_subnet_ids" {
value = "${module.vpc.public_subnets[*]}"
}

output "db_subnet_ids" {
value = "${module.vpc.database_subnets[*]}"
}

output "db_group_name" {
    value = "${module.vpc.database_subnet_group}"
}

