variable "aws_region" {
  description = "The AWS region to deploy into (e.g. us-east-1)."
  default     = "us-east-1"
}

variable "master_ami_id" {
  description = "ID of AMI to use for master instance(s)"
  default     = ""
}

variable "instance_type_master" {
  description = "Instance Type to use for master instance(s)"
  default     = "t2.micro"
}

variable "http_port" {
  description = "The port to use for HTTP traffic to Jenkins"
  default     = 8080
}

variable "jnlp_port" {
  description = "The Port to use for Jenkins master to slave communication bewtween instances"
  default     = 49187
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  default     = ""
}

variable "ssh_key_path" {
  description = "The path of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Used for provisioning."
  default     = ""
}

variable "plugins" {
  type        = "list"
  description = "A list of Jenkins plugins to install, use short names."
  default     = ["git", "xunit"]
}

variable "tags" {
  type = "map"
  description = "Supply tags you want added to all resources"
  default = {
  }
}