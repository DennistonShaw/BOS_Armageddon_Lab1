############################################
# ALB Listeners: HTTP → HTTPS redirect, HTTPS → Target Group
############################################

# HTTP listener: Redirects all traffic to HTTPS (the "decoy airlock")
resource "aws_lb_listener" "edo_http_listener01" {
  load_balancer_arn = aws_lb.edo_alb01.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS listener: Terminates TLS and forwards to the target group (the "real entrance")
# resource "aws_lb_listener" "edo_https_listener01" {
#   provider = aws.ap-northeast-1   # ← IMPORTANT: Match your ALB region (adjust alias if different)

#   load_balancer_arn = aws_lb.edo_alb01.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

#   # Reference the CERTIFICATE ARN, not the validation ARN
#   certificate_arn = aws_acm_certificate.edo_acm_cert01.arn  # ← CHANGE THIS to your actual certificate resource name

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.edo_tg01.arn
#   }

#   depends_on = [
#     aws_acm_certificate_validation.edo_acm_validation01
#   ]
# }

### Lab 2a - Origin Header Protection (Chewbacca’s secret handshake)

# Generate a random secret value for the origin header
resource "random_password" "edo_origin_header_value01" {
  length  = 32
  special = false
}

# Rule 1: Require the secret header → forward to target group if present
# resource "aws_lb_listener_rule" "edo_require_origin_header01" {
#   listener_arn = aws_lb_listener.edo_https_listener01.arn
#   priority     = 10

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.edo_tg01.arn
#   }

#   condition {
#     http_header {
#       http_header_name = "X-edo-Growl"
#       values           = [random_password.edo_origin_header_value01.result]
#     }
#   }

#   depends_on = [aws_lb_listener.edo_https_listener01]
#}

# Rule 2: Catch-all default → return 403 Forbidden if no matching rule
# resource "aws_lb_listener_rule" "edo_default_block01" {
#   listener_arn = aws_lb_listener.edo_https_listener01.arn
#   priority     = 99

#   action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "Forbidden"
#       status_code  = "403"
#     }
#   }

#   condition {
#     path_pattern {
#       values = ["*"]
#     }
#   }

#   depends_on = [aws_lb_listener.edo_https_listener01]
# }