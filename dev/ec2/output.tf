output "ec2_id" {
  value = {
    waf = module.ec2_waf.id
    web = module.ec2_web.id
    was = module.ec2_was.id
    }
}