output "security_ids" {
    value = {
        pub_alb = "${module.security_group_pub_alb.security_group_id}"
        pri_web_alb = "${module.security_group_pri_web_alb.security_group_id}"
        pri_was_alb = "${module.security_group_pri_was_alb.security_group_id}"
        waf = "${module.security_group_waf.security_group_id}"
        web = "${module.security_group_web.security_group_id}"
        was = "${module.security_group_was.security_group_id}"
        db = "${module.security_group_db.security_group_id}"
    }
}
