resource "aws_instance" "ec2_jenkins" {
  count                  = 1
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  user_data              = "${var.user_data}"
  key_name               = "${var.ssh_key_name}"
  monitoring             = true
  vpc_security_group_ids = ["${module.security_group_rules.jenkins_security_group_id}"]
  tags                   = "${var.tag}"

  provisioner "file" {
    connection  = {
      user = "ec2-user"
      private_key = "${file(var.ssh_key_path)}"
    }
    content     = "${var.setup_data}"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    connection  = {
      user = "ec2-user"
      private_key = "${file(var.ssh_key_path)}"
    }
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh"
    ]
  }
}

module "security_group_rules" {
  source = "../jenkins-security-group-rules"

  name      = "${var.name}"
  allowed_inbound_cidr_blocks = ["${var.allowed_inbound_cidr_blocks}"]
  allowed_ssh_cidr_blocks = ["${var.allowed_ssh_cidr_blocks}"]

  http_port = "${var.http_port}"
  https_port = "${var.https_port}"
  jnlp_port = "${var.jnlp_port}"
}
