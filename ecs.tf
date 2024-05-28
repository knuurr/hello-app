# Create an ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "app-hello-ecs-cluster" # Name of the ECS cluster
}


# Load a JSON template file for the container definitions and replace variables
data "template_file" "hello_app" {
  template = file("./templates/ecs/hello_app.json.tpl") # Path to the template file

  vars = {
    app_image      = var.app_image      # Docker image for the application
    app_port       = var.app_port       # Application port
    fargate_cpu    = var.fargate_cpu    # CPU units for Fargate
    fargate_memory = var.fargate_memory # Memory for Fargate
    aws_region     = var.aws_region     # AWS region
  }
}

# Define an ECS task with the specified resource requirements and container definitions
resource "aws_ecs_task_definition" "app" {
  family                   = "app-hello-ecs-task"                     # Family name for the task definition
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn # ARN of the IAM role for the task execution
  network_mode             = "awsvpc"                                 # Network mode for the task
  requires_compatibilities = ["FARGATE"]                              # Specify that the task will run on Fargate
  cpu                      = var.fargate_cpu                          # CPU units for Fargate
  memory                   = var.fargate_memory                       # Memory for Fargate
  container_definitions    = data.template_file.hello_app.rendered    # Container definitions from the template file
}
# Create an ECS service to run the tasks
resource "aws_ecs_service" "main" {
  name            = "app-hello-ecs-service"         # Name of the ECS service
  cluster         = aws_ecs_cluster.main.id         # ID of the ECS cluster
  task_definition = aws_ecs_task_definition.app.arn # ARN of the task definition
  desired_count   = var.app_count                   # Desired number of tasks
  launch_type     = "FARGATE"                       # Launch type (Fargate)

  # Network configuration for the ECS service
  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id] # Security groups for the ECS tasks
    subnets          = aws_subnet.private.*.id           # Subnets for the ECS tasks
    assign_public_ip = false                             # Assign a public IP to the tasks
  }

  # Associate the ECS service with a load balancer
  load_balancer {
    target_group_arn = aws_alb_target_group.app.id # ARN of the target group
    container_name   = "app-hello"                 # Name of the container
    container_port   = var.app_port                # Port of the container
  }

  # Dependencies to ensure proper order of resource creation
  depends_on = [
    aws_alb_listener.front_end,                                              # Ensure the ALB listener is created before the ECS service
    aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment # Ensure the IAM role policy is attached before the ECS service
  ]
}
