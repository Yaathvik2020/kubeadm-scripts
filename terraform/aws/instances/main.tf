provider "aws" {
  region = "ap-south-1"
}

module "ec2_instance" {
  source = "../modules/ec2"

  instance_name  = "k8s-node"
  ami_id         = "ami-02b8269d5e85954ef"
  instance_type  = "m7i-flex.large"
  key_name       = "88chinna"
  subnet_ids     = ["subnet-0703f93259db458bc", "subnet-03438a2cfcacb67bc", "subnet-068fc4dd89edb5afe"]
  instance_count = 3

inbound_from_port  = ["0", "6443", "22", "30000", "0"]
inbound_to_port    = ["65000", "6443", "22", "32768", "65000"]
inbound_protocol   = ["TCP", "TCP", "TCP", "TCP", "TCP"]
inbound_cidr       = ["172.31.0.0/16", "0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0", "10.244.0.0/16"]
outbound_from_port = ["0"]
outbound_to_port   = ["0"]
outbound_protocol  = ["-1"]
outbound_cidr      = ["0.0.0.0/0"]
}
