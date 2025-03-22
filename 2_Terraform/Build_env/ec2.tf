data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

locals {
  name   = "Bing-bastion"
  region = "ap-northeast"
  azs    = "ap-northeast-1a"

  user_data = <<-EOT
    #!/bin/bash
    sudo su
    sudo apt-get update
    sudo apt-get upgrade -y
    cd /tmp
    sudo apt install unzip
    # install aws cli
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    # install eksctl
    ## for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
    ARCH=amd64
    PLATFORM=$(uname -s)_$ARCH
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
    tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
    sudo mv /tmp/eksctl /usr/local/bin

    # install kubectl
    curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.0/2024-09-12/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH

    # install helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh



  EOT

}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "bing-terraform-sg"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = aws_vpc.main.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-all"]
  egress_rules        = ["all-all"]

}
resource "aws_iam_instance_profile" "profile" {
  name = "bingec2-admin-profile"
  role = aws_iam_role.role.name
}


module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = local.name

  ami                         = data.aws_ami.ubuntu.id
  availability_zone           = local.azs
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public_subnet["subnet1"].id
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.profile.name
  key_name                    = "bing-nl-person"
  metadata_options = {
    http_tokens = "required"
  }
  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 10
    },
  ]
  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true
}






