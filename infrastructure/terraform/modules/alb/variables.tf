variable "environment" {
  description = "Environment name"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 5000
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

variable "enable_https" {
  description = "Enable HTTPS"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "SSL certificate ARN"
  type        = string
  default     = ""
} 