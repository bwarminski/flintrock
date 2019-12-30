

data "aws_vpc" "selected" {
  id = var.vpc_id
  default = var.vpc_id == null ? true : false
}

data "http" "flintrock_client_ip" { // Don't like this, but let's keep it pure
  url = "http://ipv4.icanhazip.com"
}

data "aws_ami" "ami" {
  owners = ["self"]
  most_recent = true
  filter {
    name   = "name"
    values = ["flintrock-${var.cluster_name}-*"]
  }
}

resource "aws_eip" "ips" {
  count = 1 + var.num_slaves
  vpc = true
}

resource "aws_instance" "instances" {
  count = 1 + var.num_slaves
  ami = data.aws_ami.ami.id
  instance_type = var.instace_type
  root_block_device {
    encrypted = false
    volume_size = var.volume_size
    volume_type = "gp2"
  }
  ephemeral_block_device {
    device_name = "/dev/sdb"
    virtual_name = "ephemeral0"
  }
  ephemeral_block_device {
    device_name = "/dev/sdc"
    virtual_name = "ephemeral1"
  }
  ephemeral_block_device {
    device_name = "/dev/sdd"
    virtual_name = "ephemeral2"
  }
  ephemeral_block_device {
    device_name = "/dev/sde"
    virtual_name = "ephemeral3"
  }
  ephemeral_block_device {
    device_name = "/dev/sdf"
    virtual_name = "ephemeral4"
  }
  ephemeral_block_device {
    device_name = "/dev/sdg"
    virtual_name = "ephemeral5"
  }
  ephemeral_block_device {
    device_name = "/dev/sdh"
    virtual_name = "ephemeral6"
  }
  ephemeral_block_device {
    device_name = "/dev/sdi"
    virtual_name = "ephemeral7"
  }
  ephemeral_block_device {
    device_name = "/dev/sdj"
    virtual_name = "ephemeral8"
  }
  ephemeral_block_device {
    device_name = "/dev/sdk"
    virtual_name = "ephemeral9"
  }
  ephemeral_block_device {
    device_name = "/dev/sdl"
    virtual_name = "ephemeral10"
  }
  ephemeral_block_device {
    device_name = "/dev/sdm"
    virtual_name = "ephemeral1"
  }
  availability_zone = var.availability_zone
  tenancy = var.tenancy
  placement_group = var.placement_group
  security_groups = concat([aws_security_group.cluster-group.name, aws_security_group.flintrock_group.name], var.security_groups)
  subnet_id = var.subnet_id
  iam_instance_profile = var.instance_profile
  ebs_optimized = var.ebs_optimized
  instance_initiated_shutdown_behavior = var.instance_shutdown_behavior
  user_data = templatefile("${path.module}/userdata.sh.tpl", {
    master_host = aws_eip.ips[0].public_dns,
    slave_hosts = length(aws_eip.ips.*.public_dns) > 1 ? slice(aws_eip.ips.*.public_dns, 1, length(aws_eip.ips.*.public_dns)) : []
    master_node = count.index == 0
  })
  tags = {
    Name = "${var.cluster_name}-${count.index == 0 ? "master" : "slave"}"
    flintrock-role = count.index == 0 ? "master" : "slave"
  }
  key_name = var.key_name
}

resource "aws_eip_association" "associations" {
  count = 1 + var.num_slaves
  allocation_id = aws_eip.ips[count.index].id
  instance_id = aws_instance.instances[count.index].id
}