terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}


module "ssh_key_pair" {
  source = "cloudposse/ssh-key-pair/tls"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"
  namespace             = "eg"
  stage                 = "test"
  name                  = "app"
  ssh_public_key_path   = "./secrets"
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
  chmod_command         = "chmod 600 %v"
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = module.ssh_key_pair.public_key
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"


  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_instance" "app_server" {
  ami             = "ami-0b28dfc7adc325ef4"
  instance_type   = "t2.micro"
  key_name        = var.public_key
  security_groups = [aws_security_group.allow_ssh.name]


  tags = {
    Name = "ExampleAppServerInstance"
  }

  provisioner "remote-exec" {

    
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl status nginx",
      "curl http://localhost"
    ]

    connection {
      type     = "ssh"
      user     = "ec2-user"
      #private_key = module.ssh_key_pair.private_key
      private_key ="${file("${var.key_path}/${var.private_key_name}")}"
      host     = self.public_ip
      agent    = true
    }

  }

}



