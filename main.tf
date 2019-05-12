# Create Jenkins Instance using Terraform
# @author Huzefa Hamdard

#Put terraform state file to S3
terraform{
    backend "s3"{
    }
}

#Tell terraform that we will use AWS provider
provider "aws" {
  region = "${var.aws_region}"
}

provider "template"{
    version = "~> 0.1"
}

#Set path to store terraform state file. 
data "terraform_remote_state" "jenkins_state" {
    backend = "s3"
    config {
        bucket = "${var.s3prefix}-terraform-states-${var.region}"
        key = "${var.env_name}/jenkins.tfstate"
        region = "${var.region}"
    }
}

module "jenkins" {
  source                      = "./modules/jenkins"

  vpc_id                      = "${data.aws_vpc.default.id}"

  #name                        = "${var.name == "" ? "jenkins" : join("-", list(var.name, "jenkins"))}"
  name                        = "jenkins"
  #alb_prefix                  = "${var.name == "" ? "jenkins" : join("-", list(var.name, "jenkins"))}"
  instance_type               = "${var.instance_type_master}"

  ami_id                      = "${var.master_ami_id == "" ? data.aws_ami.jenkins.image_id : var.master_ami_id}"
  user_data                   = ""
  setup_data                  = "${data.template_file.setup_data_master.rendered}"

  http_port                   = "${var.http_port}"
  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"
  ssh_key_path                = "${var.ssh_key_path}"

  # Config used by the Application Load Balancer
  subnet_ids                  = "${data.aws_subnet_ids.default.ids}"
  aws_ssl_certificate_arn     = "${var.aws_ssl_certificate_arn}"
  dns_zone                    = "${var.dns_zone}"
  app_dns_name                = "${var.app_dns_name}"
}

data "template_file" "setup_data" {
  template = "${file("./modules/jenkins/setup.tpl")}"

  vars = {
    jnlp_port = "${var.jnlp_port}"
    plugins = "${join(" ", var.plugins)}"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}


