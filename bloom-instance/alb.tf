# Anything related to our Application Load Balancer goes here

resource "aws_lb" "public_alb" {
  name               = "${local.default_name}-Public-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_alb.id]

  # Note that an ALB requires at least 2 subnets
  subnets = [for subnet in module.network.subnets.public : subnet.id]

  enable_deletion_protection = false

  /*
  access_logs {
    bucket  = aws_s3_bucket.logging_bucket.id
    prefix  = "public-alb-logs"
    enabled = true
  }
  */
}

# A Listener defines how to handle certain requests
# This Listener returns a 404 status code for any request on port 80
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }
}

# ALBs need Security Groups, too
# This one enables access from any external IP
resource "aws_security_group" "public_alb" {
  name        = "${local.default_name}-Public-ALB"
  description = "Enable access to public ALB"
  vpc_id      = module.network.vpc.id

  ingress {
    description = "Allow HTTP from Internet on port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.network.vpc.cidr_block]
  }

  egress {
    description      = "Allow all egress"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
