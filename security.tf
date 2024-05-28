# ALB security Group: Edit to restrict access to the application
resource "aws_security_group" "lb" {
  name        = "app-hello-load-balancer-sg"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.main.id

  # Ingress rule to allow traffic on the specified application port from any source
  ingress {
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all outbound traffic
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "app-hello-ecs-tasks-sg"                 # Name of the ECS tasks security group
  description = "Allow inbound access from the ALB only" # Description of the security group
  vpc_id      = aws_vpc.main.id                          # ID of the VPC

  # Ingress rule to allow inbound traffic from the ALB security group only
  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.lb.id] # Allow traffic only from the ALB security group
  }

  # Egress rule to allow outbound traffic
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
