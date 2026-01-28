############################################
# ACM Certificate (TLS) for app.chewbacca-growl.com
############################################

# Explanation: TLS is the diplomatic passport — browsers trust you, and Chewbacca stops growling at plaintext.
resource "aws_acm_certificate" "edo_acm_cert01" {
  provider = aws.use1
  domain_name               = "larrryharrisaws.com"
  subject_alternative_names = ["*.larrryharrisaws.com"]
  validation_method         = var.certificate_validation_method

  # TODO: students can add subject_alternative_names like var.domain_name if desired

  tags = {
    Name = "${var.project_name}-acm-cert01"
  }
}


# Explanation: Once validated, ACM becomes the “green checkmark” — until then, ALB HTTPS won’t work.
resource "aws_acm_certificate_validation" "edo_acm_validation01" {
  provider = aws.us-east-1
  certificate_arn = aws_acm_certificate.edo_acm_cert01.arn


  #adding from the template resource below as test
  validation_record_fqdns = [
    for r in aws_route53_record.edo_acm_validation_records01 : r.fqdn
  ]

  timeouts {
    create = "30m" # optional: give more time if propagation is slow
  }
}

# # Explanation: This ties the “proof record” back to ACM—Chewbacca gets his green checkmark for TLS.
# resource "aws_acm_certificate_validation" "edo_acm_validation01_dns_bonus" {
#   count = var.certificate_validation_method == "DNS" ? 1 : 0

#   certificate_arn = aws_acm_certificate.edo_acm_cert01.arn

#   validation_record_fqdns = [
#     for r in aws_route53_record.edo_acm_validation_records01 : r.fqdn
#   ]

#   timeouts {
#     create = "30m"  # optional: give more time if propagation is slow
#   }
# }