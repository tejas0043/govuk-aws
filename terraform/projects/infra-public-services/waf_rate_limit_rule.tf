resource "aws_wafv2_web_acl" "ip_rate_limit_rule" {
  name        = "WAFRateLimit"
  description = "Enforces a rate limit per IP address using the True-Client-IP header."
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  rule {
    name     = "rate-limit-on-True-Client-IP"
    priority = 1

    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = 15000 # per 5 minute window (50 requests per second)
        aggregate_key_type = "FORWARDED_IP"

        forwarded_ip_config {
          fallback_behaviour = "NO_MATCH"
          header_name = "True-Client-IP"
        }
      }
    }
  }
}
