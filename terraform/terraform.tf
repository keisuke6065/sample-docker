variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "ssh_key_name" {}
variable "my_domain" {}

variable "region" {
  default = "ap-northeast-1"
}

variable "availability-zone" {
  type = "list"

  default = [
    "ap-northeast-1a",
    "ap-northeast-1c",
  ]
}

variable "ami_images" {
  default = "ami-92df37ed"
}

variable "instance-type" {
  default = "t2.micro"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

// ==========================================================
// route53
// ==========================================================

//resource "aws_route53_zone" "dev" {
//  name = "${var.my_domain}"
//  name_servers = [
//    "ns-1490.awsdns-58.org",
//    "ns-534.awsdns-02.net",
//    "ns-1668.awsdns-16.co.uk",
//    "ns-231.awsdns-28.com"]
//  tags {
//    Environment = "main"
//  }
//}
//resource "aws_route53_record" "sample" {
//  zone_id = "Z14GRHDCWA56QT"
//  name = "sample"
//  type = "A"
//  alias {
//    name = "${aws_alb.sample-docker-alb.dns_name}"
//    zone_id = "${aws_alb.sample-docker-alb.zone_id}"
//    evaluate_target_health = true
//  }
//}

// ==========================================================
// vpc
// ==========================================================

resource "aws_vpc" "sample-ecs" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "false"

  tags {
    Name = "sample-ecs-vpc"
  }
}

// ==========================================================
// nat
// ==========================================================

resource "aws_internet_gateway" "ecs-gw" {
  vpc_id = "${aws_vpc.sample-ecs.id}"
}

// ==========================================================
// subnet
// ==========================================================

resource "aws_subnet" "ecs-subnet-a" {
  cidr_block        = "10.1.1.0/24"
  vpc_id            = "${aws_vpc.sample-ecs.id}"
  availability_zone = "${var.availability-zone[0]}"
}

resource "aws_subnet" "ecs-subnet-c" {
  cidr_block        = "10.1.2.0/24"
  vpc_id            = "${aws_vpc.sample-ecs.id}"
  availability_zone = "${var.availability-zone[1]}"
}

resource "aws_route_table" "ecs-route" {
  vpc_id = "${aws_vpc.sample-ecs.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ecs-gw.id}"
  }
}

resource "aws_route_table_association" "a-route" {
  route_table_id = "${aws_route_table.ecs-route.id}"
  subnet_id      = "${aws_subnet.ecs-subnet-a.id}"
}

resource "aws_route_table_association" "c-route" {
  route_table_id = "${aws_route_table.ecs-route.id}"
  subnet_id      = "${aws_subnet.ecs-subnet-c.id}"
}

// ==========================================================
// security group
// ==========================================================

resource "aws_security_group" "ecs-sevurity-group" {
  name   = "ecs-sevurity-group"
  vpc_id = "${aws_vpc.sample-ecs.id}"

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 80
    protocol  = "tcp"
    to_port   = 80

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

// ==========================================================
// iam role
// ==========================================================

//resource "aws_iam_role" "sample-ecs-iam-role" {
//  name = "sample-ecs-iam-role"
//  assume_role_policy = "${file("iam-role/ecs-role.json")}"
//}
//
//resource "aws_iam_instance_profile" "sample-ecs-iam-instance-profile" {
//  name = "sample-ecs-iam-instance-profile"
//  role = "${aws_iam_role.sample-ecs-iam-role.name}"
//}
//
//resource "aws_iam_policy" "sample-ecs-iam-policy" {
//  name = "sample-ecs-iam-role-policy"
//  policy = "${file("iam-role/ecs-iam-role-policy.json")}"
//}
//
//resource "aws_iam_role_policy_attachment" "sample-attachment" {
//  policy_arn = "${aws_iam_policy.sample-ecs-iam-policy.arn}"
//  role = "${aws_iam_role.sample-ecs-iam-role.name}"
//}

// ==========================================================
// ecs
// ==========================================================

resource "aws_ecs_cluster" "sample-cluster" {
  name = "sample-cluster"
}

resource "aws_ecs_task_definition" "sample-task" {
  container_definitions = "${file("task-definition/smple-task.json")}"
  network_mode          = "bridge"
  family                = "sample-task"
}

resource "aws_ecs_service" "sample-service" {
  name            = "sample-service"
  task_definition = "${aws_ecs_task_definition.sample-task.id}"
  cluster         = "${aws_ecs_cluster.sample-cluster.id}"

  //  iam_role = "${aws_iam_role.sample-ecs-iam-role.id}"
  desired_count = 2

  load_balancer {
    target_group_arn = "${aws_alb_target_group.sample-docker-tartget-group.id}"
    container_name   = "sample-task-ver1"
    container_port   = 8080
  }

  depends_on = [
    "aws_alb_listener.sample-docker-alb-listener",
  ]
}

// ==========================================================
// alb
// ==========================================================

resource "aws_alb_target_group" "sample-docker-tartget-group" {
  name     = "sample-docker-tartget-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.sample-ecs.id}"
}

resource "aws_alb" "sample-docker-alb" {
  name = "sample-docker-alb"

  subnets = [
    "${aws_subnet.ecs-subnet-a.id}",
    "${aws_subnet.ecs-subnet-c.id}",
  ]

  security_groups = [
    "${aws_security_group.ecs-sevurity-group.id}",
  ]
}

resource "aws_alb_listener" "sample-docker-alb-listener" {
  "default_action" {
    target_group_arn = "${aws_alb_target_group.sample-docker-tartget-group.id}"
    type             = "forward"
  }

  load_balancer_arn = "${aws_alb.sample-docker-alb.id}"
  port              = 80
  protocol          = "HTTP"
}

// ==========================================================
// instance
// ==========================================================

resource "aws_instance" "sample-docker-instance-a" {
  count                       = 1
  ami                         = "${var.ami_images}"
  instance_type               = "${var.instance-type}"
  key_name                    = "${var.ssh_key_name}"
  associate_public_ip_address = "true"

  vpc_security_group_ids = [
    "${aws_security_group.ecs-sevurity-group.id}",
  ]

  iam_instance_profile = "ecsInstanceRole"
  subnet_id            = "${aws_subnet.ecs-subnet-a.id}"

  root_block_device = {
    volume_type = "gp2"
    volume_size = "10"
  }

  tags {
    Name = "sample-ec2-a"
  }

  user_data = "${file("./user-data/user-data.sh")}"

  //  user_data = "#!/bin/bash\necho ECS_CLUSTER='${aws_ecs_cluster.sample-cluster.name}' > /etc/ecs/ecs.config"
}

resource "aws_instance" "sample-docker-instance-c" {
  count                       = 1
  ami                         = "${var.ami_images}"
  instance_type               = "${var.instance-type}"
  key_name                    = "${var.ssh_key_name}"
  associate_public_ip_address = "true"

  vpc_security_group_ids = [
    "${aws_security_group.ecs-sevurity-group.id}",
  ]

  iam_instance_profile = "ecsInstanceRole"
  subnet_id            = "${aws_subnet.ecs-subnet-c.id}"

  root_block_device = {
    volume_type = "gp2"
    volume_size = "8"
  }

  //  ebs_block_device = {
  //    device_name = "/dev/sdf"
  //    volume_type = "gp2"
  //    volume_size = "100"
  //  }

  tags {
    Name = "sample-ec2-c"
  }

  //  user_data = "${file("./user-data/user-data.sh")}"
  //  user_data = "#!/bin/bash\necho ECS_CLUSTER='${aws_ecs_cluster.sample-cluster.name}' > /etc/ecs/ecs.config"
}

resource "aws_ebs_volume" "jenkins_ebs" {
  availability_zone = "${var.availability-zone[0]}"
  size              = 40

  tags {
    Name = "sample-ebs"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  skip_destroy = "true"
  device_name  = "/dev/sdf"
  volume_id    = "${aws_ebs_volume.jenkins_ebs.id}"
  instance_id  = "${aws_instance.sample-docker-instance-a.id}"
}

// ==========================================================
// output
// ==========================================================

output "public ip of sample-docker-instance-a" {
  value = [
    "${aws_instance.sample-docker-instance-a.public_ip}",
    "${aws_instance.sample-docker-instance-c.public_ip}",
    "${aws_alb.sample-docker-alb.dns_name}",
  ]
}

