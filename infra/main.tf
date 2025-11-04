provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "demo-artifacts-bucket-gerard"
}

resource "aws_iam_role" "codedeploy_role" {
  name = "CodeDeployServiceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_instance" "demo_ec2" {
  ami           = "ami-0bdd88bd06d16ba03" # Amazon Linux 2 (us-east-1)
  instance_type = "t2.micro"

  tags = {
    Name = "DemoEC2"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install ruby -y
              yum install wget -y
              cd /home/ec2-user
              wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
              chmod +x ./install
              ./install auto
              EOF
}

resource "aws_codedeploy_app" "demo_app" {
  name             = "DemoWebApp"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "demo_group" {
  app_name              = aws_codedeploy_app.demo_app.name
  deployment_group_name = "DemoGroup"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "DemoEC2"
    }
  }
}
