terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.42"
    }
  }

  required_version = ">= 0.14.9"
}

locals {
  user_data = <<EOF
#!/bin/bash
sudo curl -sSL https://agent.armor.com/latest/armor_agent.sh | sudo bash /dev/stdin -l XXXXX-XXXXX-XXXXX-XXXXX-XXXXX -r us-west-armor -f
EOF
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0d4c664d2c7345cf1"
  instance_type = "t2.micro"

  user_data_base64 = base64encode(local.user_data)

  key_name = aws_key_pair.terraform_pub_key.key_name

  tags = {
    Name = var.instance_name
  }
}

resource "aws_key_pair" "terraform_pub_key" {
  public_key = file("~/.ssh/<your keypair name>.pub")
}

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}
