resource "aws_security_group" "flintrock_group" {
  name = "flintrock"
  description = "Flintrock base group"
  vpc_id = data.aws_vpc.selected.id
}

resource "aws_security_group_rule" "ssh" {
  type = "ingress"
  protocol = "tcp"
  from_port = 22
  to_port = 22
  cidr_blocks = ["${chomp(data.http.flintrock_client_ip.body)}/32"]
  security_group_id = aws_security_group.flintrock_group.id
}

resource "aws_security_group_rule" "hdfs" {
  type = "ingress"
  protocol = "tcp"
  from_port = 50070
  to_port = 50070
  cidr_blocks = ["${chomp(data.http.flintrock_client_ip.body)}/32"]
  security_group_id = aws_security_group.flintrock_group.id
}

resource "aws_security_group_rule" "spark-1" {
  type = "ingress"
  protocol = "tcp"
  from_port = 8080
  to_port = 8081
  cidr_blocks = ["${chomp(data.http.flintrock_client_ip.body)}/32"]
  security_group_id = aws_security_group.flintrock_group.id
}

resource "aws_security_group_rule" "spark-2" {
  type = "ingress"
  protocol = "tcp"
  from_port = 4040
  to_port = 4050
  cidr_blocks = ["${chomp(data.http.flintrock_client_ip.body)}/32"]
  security_group_id = aws_security_group.flintrock_group.id
}

resource "aws_security_group_rule" "spark-3" {
  type = "ingress"
  protocol = "tcp"
  from_port = 7077
  to_port = 7077
  cidr_blocks = ["${chomp(data.http.flintrock_client_ip.body)}/32"]
  security_group_id = aws_security_group.flintrock_group.id
}

resource "aws_security_group_rule" "spark-rest" {
  type = "ingress"
  protocol = "tcp"
  from_port = 6066
  to_port = 6066
  cidr_blocks = ["${chomp(data.http.flintrock_client_ip.body)}/32"]
  security_group_id = aws_security_group.flintrock_group.id
}

resource "aws_security_group" "cluster-group" {
  name = "flintrock-${var.cluster_name}"
  description = "Flintrock cluster group"
  vpc_id = data.aws_vpc.selected.id
}

resource "aws_security_group_rule" "intracluster" {
  type = "ingress"
  protocol = "all"
  from_port = -1
  to_port = -1
  self = true
  security_group_id = aws_security_group.cluster-group.id
}

resource "aws_security_group_rule" "outbound" {
  type = "egress"
  protocol = "all"
  from_port = -1
  to_port = -1
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster-group.id
}

