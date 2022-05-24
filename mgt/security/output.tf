output "security_ids" {
    value = {
        jenkins = "${module.security_group_jenkins.security_group_id}"
        gitlab = "${module.security_group_gitlab.security_group_id}"
        prd_bastion = "${module.security_group_prd_bastion.security_group_id}"
        dev_bastion = "${module.security_group_dev_bastion.security_group_id}"
   }
}