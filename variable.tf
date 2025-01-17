variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "ec2_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "hello-EcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
  description = "ECS auto scale role name"
  default     = "hello-EcsAutoScaleRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "3"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "nginxdemos/hello:latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 3
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}
