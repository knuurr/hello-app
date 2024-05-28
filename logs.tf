# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "hello_log_group" {
  name              = "/ecs/hello-app"
  retention_in_days = 7

  tags = {
    Name = "app-hello-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "hello_log_stream" {
  name           = "app-hello-log-stream"
  log_group_name = aws_cloudwatch_log_group.hello_log_group.name
}

