data "aws_ami" "t2-medium-server" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_launch_configuration" "project-1-conf" {
  name_prefix   = "project-1-lc"
  image_id      = data.aws_ami.t2-medium-server.id
  instance_type = "t2.medium"
  key_name      = "Project-1-key"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "project-1-autoscaling-group" {
  name                      = "project-1-asg"
  vpc_zone_identifier       = ["${aws_subnet.private-subnet.id}"]
  launch_configuration      = aws_launch_configuration.project-1-conf.name
  min_size                  = 1
  max_size                  = 5
  health_check_grace_period = 300
  health_check_type         = "EC2"

  tag {
    key                 = "Name"
    value               = "t2-medium-server"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Policy
resource "aws_autoscaling_policy" "project-1-policy-scaling" {
    name                    = "project-1-aps"
    autoscaling_group_name  = aws_autoscaling_group.project-1-autoscaling-group.name
    adjustment_type         = "ChangeInCapacity"
    scaling_adjustment      = 1
    cooldown                = 60
    policy_type             = "SimpleScaling"
  
}

resource "aws_cloudwatch_metric_alarm" "project-1-cpu-alarm-scale" {
    alarm_name          = "project-1-cpu-alarm-scale"
    alarm_description   = "CPU Usage increased"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 120
    statistic           = "Average"
    threshold           = 45

    dimensions = {
      "AutoScalingGroupName" = aws_autoscaling_group.project-1-autoscaling-group.name
    }
    actions_enabled = true
    alarm_actions   = [aws_autoscaling_policy.project-1-policy-scaling.arn]
  
}

# Auto Descaling Policy
resource "aws_autoscaling_policy" "project-1-policy-descale" {
    name = "project-1-apd"
    autoscaling_group_name = aws_autoscaling_group.project-1-autoscaling-group.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = -1
    cooldown = 60
    policy_type = "SimpleScaling"
  
}

resource "aws_cloudwatch_metric_alarm" "project-1-cpu-alarm-descale" {
    alarm_name = "project-1-cpu-alarm-descale"
    alarm_description = "CPU Usage decreased"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = 120
    statistic = "Average"
    threshold = 40

    dimensions = {
      "AutoScalingGroupName" = aws_autoscaling_group.project-1-autoscaling-group.name
    }
    actions_enabled = true
    alarm_actions = [aws_autoscaling_policy.project-1-policy-descale.arn]
  
}