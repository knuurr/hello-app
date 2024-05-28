# Create an Application Load Balancer (ALB)
resource "aws_lb" "main" {
  name               = "app-hello-load-balancer"  # Name of the ALB
  subnets            = aws_subnet.public.*.id     # Subnets where the ALB will be deployed
  security_groups    = [aws_security_group.lb.id] # Security groups associated with the ALB
  load_balancer_type = "application"

  # Enable WAF on the load balancer
  drop_invalid_header_fields = true
  # enable_waf_fail_open       = true # Allows traffic if WAF is unavailable

  # Access log configuration
  # access_logs {
  # bucket  = aws_s3_bucket.lb_logs.id
  # prefix  = "app-home-lb"
  # enabled = true
  # }

}
# Define a target group for the ALB
resource "aws_alb_target_group" "app" {
  name        = "app-hello-target-group" # Name of the target group
  port        = 80                       # Port on which the targets are listening
  protocol    = "HTTP"                   # Protocol used by the targets
  vpc_id      = aws_vpc.main.id          # VPC ID where the targets are located
  target_type = "ip"                     # Type of targets (IP addresses)

  # Configure health checks for the target group
  health_check {
    healthy_threshold   = "3"    # Number of consecutive successful health checks required before considering a target healthy
    interval            = "30"   # Interval (in seconds) between health checks
    protocol            = "HTTP" # Protocol used for health checks
    matcher             = "200"  # Expected HTTP status code for a successful health check
    timeout             = "3"    # Timeout (in seconds) for a health check
    path                = "/"    # Path to use for health checks
    unhealthy_threshold = "2"    # Number of consecutive failed health checks required before considering a target unhealthy
  }
}

# Create a listener to forward traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.id # ARN of the ALB
  port              = var.app_port   # Port on which the ALB will listen for incoming traffic
  protocol          = "HTTP"         # Protocol used by the ALB listener

  # Default action to forward traffic to the target group
  default_action {
    target_group_arn = aws_alb_target_group.app.id # ARN of the target group to forward traffic to
    type             = "forward"                  # Type of action (forward traffic)
  }
}
