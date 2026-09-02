# MONGODB

resource "aws_instance" "catalogue" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  subnet_id = local.private_subnet_id
  vpc_security_group_ids = [local.catalogue_sg_id]
  #iam_instance_profile = aws_iam_instance_profile.bastion.name

  tags =merge(
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )

}

resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    password = "DevOps321"
    host        =aws_instance.catalogue.private_ip
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh catalogue dev"
    ]
  }
}

resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped"
  depends_on = [terraform_data.catalogue]
}


resource "aws_ami_from_instance" "catalogue" {
  name               = "${var.project}-${var.environment}-catalogue"
  source_instance_id = aws_instance.catalogue.id
  depends_on = [ aws_ec2_instance_state.catalogue ]
  tags =merge(
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )
}

resource "aws_lb_target_group" "catalogue" {
  name     = "${var.project}-${var.environment}-catalogue"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  deregistration_delay = 30
  health_check {
    path                = "/health"
    interval            = 10
    timeout             = 2
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-299"
    port                = 8080
    protocol            = "HTTP"
  }
}
# launch template for catalogue service
resource "aws_launch_template" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue"
  image_id = aws_ami_from_instance.catalogue.id
  # Once autoscaling sees less traffic, it will terminate the instance 
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]
  # each time we apply terraform this version will be updated as default
  update_default_version = true



  # tags for launch instance  created by launch template through autoscaling
  tag_specifications {
    resource_type = "instance"

    tags =merge(
      {
          Name = "${var.project}-${var.environment}-catalogue"
      },
      local.common_tags
    )
  }
  # tags for launch volume created by instance
  tag_specifications {
    resource_type = "volume"

    tags =merge(
      {
          Name = "${var.project}-${var.environment}-catalogue"
      },
      local.common_tags
    )
  }
  # tags for launch template
  tags =merge(
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )


}

resource "aws_autoscaling_group" "catalogue" {
  name                      = "${var.project}-${var.environment}-catalogue"
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 120
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = false
  launch_template {
    id      = aws_launch_template.catalogue.id
    version = "$Latest"
  }

  vpc_zone_identifier       = [local.private_subnet_id]
  target_group_arns         = [aws_lb_target_group.catalogue.arn]


  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-catalogue"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "lorem"
    value               = "ipsum"
    propagate_at_launch = false
  }
}
#With Latest Version Of Launch Template

resource "aws_launch_template" "foobar" {
  name_prefix   = "foobar"
  image_id      = "ami-1a2b3c"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "bar" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.foobar.id
    version = "$Latest"
  }
}