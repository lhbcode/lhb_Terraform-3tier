provider "aws" {
  profile = "lg"
  region     = var.region
}

locals {
  region  = var.lookup-region_abbr["${var.region}"]
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096

  provisioner "local-exec" {
    command = <<EOF
    rm -rf ../ec2/${var.pri_key_name}-key.pem
    echo '${self.private_key_pem}' > ../ec2/${var.pri_key_name}-key.pem
    chmod 400 ../ec2/${var.pri_key_name}-key.pem
    EOF
  }
}

module "keypair" {
  source = "../../terraform/module/key"
  key_name   = "${var.project}-${var.environment}-${local.region}-key"
  public_key = tls_private_key.this.public_key_openssh
}
