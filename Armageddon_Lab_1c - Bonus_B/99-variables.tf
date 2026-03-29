variable "region" {
  description = "The region for this deployment"
  type        = string
  default     = "us-east-1"
}

variable "secret_name" {
  description = "The name of the secret"
  type        = string
  default     = "lab/rds/mysql"
}

variable "db_name" {
  description = "Name of the MySQL database to create"
  type        = string
  default     = "labmysql"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "cidr" {
  description = "The cidr block for the vpc"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  # Example default:
  default = ["10.10.30.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  # Example default:
  default = ["10.10.20.0/24", "10.10.10.0/24"]
}

variable "azs" {
  description = "List of Availability Zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "allowed_http_cidrs" {
  description = "List of CIDR blocks allowed for HTTP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed for SSH access. Empty string disables SSH access."
  type        = number
  default     = 22
}

variable "db_port" {
  description = "MySQL port"
  type        = number
  default     = 3306
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "db_engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.4.7"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB for RDS (free-tier: 20)"
  type        = number
  default     = 20
}

# DB connection "config" values (Parameter Store)
variable "db_endpoint" {
  type        = string
  description = "RDS endpoint hostname (no protocol). Example: mydb.abc123.us-east-1.rds.amazonaws.com"
}

# CloudWatch Logs
variable "app_log_group_name" {
  type        = string
  default     = "/aws/ec2/lab-rds-app"
  description = "CloudWatch log group used by the app/agent."
}

# Alarm settings
variable "alarm_name" {
  type        = string
  default     = "lab-db-connection-errors"
}

variable "error_threshold" {
  type        = number
  default     = 3
  description = "How many ERROR matches before alarming."
}

variable "alarm_period_seconds" {
  type    = number
  default = 60
}

variable "alert_email" {
  type    = string
  default = "ladorian@hotmail.com"
}

variable "alert_phone_e164" {
  type    = string
  # US number in E.164 format
  default = "+14432545476"
}

variable "sns_topic_name" {
  type    = string
  default = "lab-ops-alerts"
}

# The secret name your app uses (matches your user_data.sh)
variable "db_secret_name" {
  type    = string
  default = "lab/rds/mysql"
}

# How often to check whether the RDS endpoint resolves to a new IP
variable "rds_ip_check_rate_minutes" {
  type    = number
  default = 5
}

variable "enable_nat" {
  description = "Enable NAT for private subnet outbound internet (optional for Bonus-A)"
  type        = bool
  default     = false
}

############################################
# Bonus-B — Public ALB + TLS + WAF + Monitoring
############################################

# Root domain you own (example: chewbacca-growl.com)
variable "domain_name" {
  description = "Root DNS domain for the application"
  type        = string
  default     = "ultram.com"
}

# Subdomain for the app behind the ALB
variable "app_subdomain" {
  description = "Subdomain for the application (ex: app)"
  type        = string
  default     = "app"
}

# Port your EC2 application listens on
variable "app_port" {
  description = "Application listening port on EC2 targets"
  type        = number
  default     = 80
}

# ALB name
variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "ultram-alb01"
}

# Target group name
variable "alb_target_group_name" {
  description = "ALB target group name"
  type        = string
  default     = "ultram-tg01"
}

# ACM certificate domain (computed normally but kept simple for labs)
variable "tls_domain_name" {
  description = "TLS domain name for ACM certificate"
  type        = string
  default     = "app.ultram.com"
}

# WAF Web ACL name
variable "waf_name" {
  description = "WAF Web ACL name"
  type        = string
  default     = "ultram-waf01"
}

# ALB 5XX alarm settings
variable "alb_5xx_alarm_name" {
  description = "CloudWatch alarm for ALB 5xx errors"
  type        = string
  default     = "ultram-alb-5-spike"
}

variable "alb_5xx_threshold" {
  description = "5xx error count threshold before alarming"
  type        = number
  default     = 5
}

variable "alb_5xx_period_seconds" {
  description = "Evaluation period for ALB 5xx alarm"
  type        = number
  default     = 300
}

# CloudWatch dashboard name
variable "alb_dashboard_name" {
  description = "CloudWatch dashboard name for ALB metrics"
  type        = string
  default     = "ultram-alb-dashboard"
}

variable "aws_profile" {
  description = "Whether to deploy the Application Load Balancer and related resources"
  type        = string
  default     = "prod"
}

