#################### VPC ####################
resource "aws_vpc" "jenkins_network" {
  region               = var.aws_region
  cidr_block           = var.aws_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.project_tags, { Name = "jenkins_network_vpc" })
}

resource "aws_internet_gateway" "vpc_igw" {
  region     = var.aws_region
  vpc_id     = aws_vpc.jenkins_network.id
  tags       = merge(var.project_tags, { Name = "jenkins_vpc_igw" })
  depends_on = [aws_vpc.jenkins_network]
}

resource "aws_route_table" "vcp_rt" {
  vpc_id = aws_vpc.jenkins_network.id

  route {
    cidr_block = var.aws_vpc_cidr
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }

  tags = merge(var.project_tags, { Name = "jenkins_vpc_rt" })
  depends_on = [
    aws_vpc.jenkins_network,
    aws_internet_gateway.vpc_igw
  ]
}

resource "aws_subnet" "vpc_sn" {
  vpc_id     = aws_vpc.jenkins_network.id
  cidr_block = var.aws_subnet_cidr
  tags       = merge(var.project_tags, { Name = "jenkins_sn" })
  depends_on = [
    aws_vpc.jenkins_network,
    aws_internet_gateway.vpc_igw,
    aws_route_table.vcp_rt
  ]
}

resource "aws_route_table_association" "subnet_ass_rt" {
  subnet_id      = aws_subnet.vpc_sn.id
  route_table_id = aws_route_table.vcp_rt.id
  depends_on = [
    aws_route_table.vcp_rt,
    aws_subnet.vpc_sn
  ]
}

#################### EC2 ####################
data "aws_ami" "debian_image" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-13-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["136693071363"]
}

resource "aws_key_pair" "kp_ec2_jenkins" {
  key_name   = var.aws_kp_name
  public_key = var.aws_ec2_public_key
  tags       = merge(var.project_tags, { Name = "Jenkins_ec2_kp" })
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "This SG allow 8080 and SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.jenkins_network.id
  tags        = merge(var.project_tags, { Name = "Jenkins_sg" })
}

resource "aws_vpc_security_group_ingress_rule" "ssh_access" {
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  depends_on        = [aws_security_group.jenkins_sg]
}

resource "aws_vpc_security_group_ingress_rule" "jenkins_access" {
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
  depends_on        = [aws_security_group.jenkins_sg]
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  depends_on        = [aws_security_group.jenkins_sg]
}

resource "aws_eip" "jenkins_public_ip" {
  network_interface = aws_network_interface.jenkins_ni.id
  tags              = merge(var.project_tags, { Name = "jenkins_public_ip" })
  depends_on        = [aws_internet_gateway.vpc_igw]
}

resource "aws_network_interface" "jenkins_ni" {
  subnet_id       = aws_subnet.vpc_sn.id
  security_groups = [aws_security_group.jenkins_sg.id]
  tags            = merge(var.project_tags, { Name = "jenkins_ec2_ni" })
}

resource "aws_instance" "jenkins_instance" {
  ami           = data.aws_ami.debian_image.id
  instance_type = var.aws_ec2_type
  key_name      = aws_key_pair.kp_ec2_jenkins.key_name
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    iops        = 3000
    throughput  = 125
    tags        = merge(var.project_tags, { Name = "jenkins_ec2_storage" })
  }
  primary_network_interface {
    network_interface_id = aws_network_interface.jenkins_ni.id
  }
  tags = merge(var.project_tags, { Name = "jenkins_ec2" })
  depends_on = [
    aws_route_table_association.subnet_ass_rt
  ]
}
