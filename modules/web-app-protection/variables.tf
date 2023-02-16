variable "cloud_armor_policy_name" {
  description = "Name of the Cloud Armor security policy."
  type        = string
}

variable "cloud_armor_policy_description" {
  description = "Name of the Cloud Armor security policy."
  type        = string
  default     = "Set Cloud Armor security policy with preconfigured rules, security rules and custom rules"
}

variable "layer_7_ddos_defense_enable" {
  type    = bool
  default = true
  description = "Enables CAAP for L7 DDoS detection"
}

variable "layer_7_ddos_defense_rule_visibility" {
  description = "Rule visibility can be one of the following: STANDARD - opaque rules. PREMIUM - transparent rules"
  type        = string
  default     = "STANDARD"
}

variable "default_rule_action" {
  description = "default rule that allows/denies all traffic with the lowest priority (2,147,483,647)"
  type        = string
  default     = "deny(403)"
}

variable "pre_configured_rules" {
  description = "Map of pre-configured rules Sensitivity levels"
  type = map(object({
    action                  = string
    priority                = number
    description             = optional(string)
    preview                 = optional(bool, false)
    redirect_type           = optional(string, null)
    target_rule_set         = string
    sensitivity_level       = optional(number, 4)
    include_target_rule_ids = optional(list(string), [])
    exclude_target_rule_ids = optional(list(string), [])
    rate_limit_options = optional(object({
      enforce_on_key                       = optional(string)
      exceed_action                        = optional(string)
      rate_limit_http_request_count        = optional(number)
      rate_limit_http_request_interval_sec = optional(number)
      ban_duration_sec                     = optional(number)
      ban_http_request_count               = optional(number)
      ban_http_request_interval_sec        = optional(number)
      }),
    {})
  }))
  default = {}
}

variable "security_rules" {
  description = "Map of Security rules with list of IP addresses to block or unblock"
  type = map(object({
    action        = string
    priority      = number
    description   = optional(string)
    preview       = optional(bool, false)
    redirect_type = optional(string, null)
    src_ip_ranges = list(string)
    rate_limit_options = optional(object({
      enforce_on_key                       = optional(string)
      exceed_action                        = optional(string)
      rate_limit_http_request_count        = optional(number)
      rate_limit_http_request_interval_sec = optional(number)
      ban_duration_sec                     = optional(number)
      ban_http_request_count               = optional(number)
      ban_http_request_interval_sec        = optional(number)
      }),
    {})
  }))
  default = {}
}

variable "custom_rules" {
  description = "Custom security rules"
  type = map(object({
    action        = string
    priority      = number
    description   = optional(string)
    preview       = optional(bool, false)
    expression    = string
    redirect_type = optional(string, null)
    rate_limit_options = optional(object({
      enforce_on_key                       = optional(string)
      exceed_action                        = optional(string)
      rate_limit_http_request_count        = optional(number)
      rate_limit_http_request_interval_sec = optional(number)
      ban_duration_sec                     = optional(number)
      ban_http_request_count               = optional(number)
      ban_http_request_interval_sec        = optional(number)
      }),
    {})
  }))
  default = {}
}

variable "enable_cdn" {
  type    = bool
  default = true
  description = "Enables Cloud CDN for HTTP Load Balancer"
}

variable "health_check" {
  type = object({
    check_interval_sec  = number
    timeout_sec         = number
    healthy_threshold   = number
    unhealthy_threshold = number
    request_path        = string
    port                = number
    host                = string
    logging             = bool
  })
  default = {
    check_interval_sec  = 10
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    request_path        = "/"
    port                = 80
    host                = null
    logging             = null
  }
  description = "Health Check specification for HTTP(S) Load Balancer"

}