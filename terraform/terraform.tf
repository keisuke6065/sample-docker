variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "ssh_key_name" {}

variable "region" {
  default = "ap-northeast-1"
}

variable "availability-zone" {
  default = "ap-northeast-1a"
}

variable "ami_images" {
  default = "ami-95903df3"
}

variable "instance-type" {
  default = "m3.medium"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

resource "aws_ecs_cluster" "sample-cluster" {
  name = "sample-cluster"
}

resource "aws_ecs_task_definition" "sample-task" {
  container_definitions = "${file("task-definition/smple-task.json")}"
  family = "sample-task"
}

resource "aws_ecs_service" "sample-service" {
  name = "sample-service"
  task_definition = "${aws_ecs_task_definition.sample-task.arn}"
  cluster = "${aws_ecs_cluster.sample-cluster.id}"
  desired_count = 1
}

resource "aws_vpc" "sample-ecs" {
  cidr_block = "10.1.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "false"
  tags {
    Name = "sample-ecs-vpc"
  }
}

resource "aws_internet_gateway" "ecs-gw" {
  vpc_id = "${aws_vpc.sample-ecs.id}"
}

resource "aws_subnet" "ecs-a-subnet" {
  cidr_block = "10.1.1.0/24"
  vpc_id = "${aws_vpc.sample-ecs.id}"
  availability_zone = "${var.availability-zone}"
}

resource "aws_route_table" "ecs-route" {
  vpc_id = "${aws_vpc.sample-ecs.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ecs-gw.id}"
  }
}

resource "aws_route_table_association" "ecs-route" {
  route_table_id = "${aws_route_table.ecs-route.id}"
  subnet_id = "${aws_subnet.ecs-a-subnet.id}"
}

resource "aws_security_group" "ecs-sevurity-group" {
  name = "ecs-sevurity-group"
  description = "Allow SSH inbound traffic"
  vpc_id = "${aws_vpc.sample-ecs.id}"
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
}

//resource "aws_launch_configuration" "ec2" {
//  image_id = "${var.ami_images}"
//  instance_type = "${var.instance-type}"
//  count = 1
//  associate_public_ip_address = true
//  key_name = "${var.ssh_key_name}"
//  name_prefix = "sample-"
//  user_data = "#!/bin/bash\necho ECS_CLUSTER='${aws_ecs_cluster.sample-cluster.name}' > /etc/ecs/ecs.config"
//  security_groups = ["${aws_security_group.ecs-sevurity-group.id}"]
//  vpc_classic_link_security_groups = ["${aws_vpc.sample-ecs.id}"]
//  iam_instance_profile = "ecs_iam_role"
//  root_block_device {
//    delete_on_termination = true
//  }
//}

//resource "aws_autoscaling_group" "bar" {
//  name = "terraform-asg-example"
//  launch_configuration = "${aws_launch_configuration.ec2.name}"
//  min_size = 1
//  max_size = 2
//  lifecycle {
//    create_before_destroy = true
//  }
//}

//
//output "public ip of sample-docker-instance" {
//  value = "${aws_launch_configuration.ec2.associate_public_ip_address}"
//}

resource "aws_instance" "sample-docker-instance" {
  count = 1
  ami = "${var.ami_images}"
  instance_type = "${var.instance-type}"
  key_name = "${var.ssh_key_name}"
  associate_public_ip_address = "true"
  vpc_security_group_ids = [
    "${aws_security_group.ecs-sevurity-group.id}",
  ]
  iam_instance_profile = "ecsInstanceRole"
  subnet_id = "${aws_subnet.ecs-a-subnet.id}"
  tags {
    Name = "sample-ec2"
  }
  user_data = "#!/bin/bash\necho ECS_CLUSTER='${aws_ecs_cluster.sample-cluster.name}' > /etc/ecs/ecs.config"
}

output "public ip of sample-docker-instance" {
  value = "${aws_instance.sample-docker-instance.public_ip}"
}
