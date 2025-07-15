variable "app_name" {
  description = "Application name used for resource naming"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.app_name))
    error_message = "App name must contain only alphanumeric characters and hyphens."
  }
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "ca-central-1"
}

# Database Configuration
variable "db_cluster_name" {
  description = "Name of the RDS cluster for database connection (empty string to skip Flyway)"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "postgres"
}

variable "db_schema" {
  description = "Database schema name"
  type        = string
  default     = "public"
}

variable "db_password" {
  description = "Database password (if not using secrets manager)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_username" {
  description = "Database username (if not using secrets manager)"
  type        = string
}

variable "db_host" {
  description = "Database host endpoint (if not using RDS cluster lookup)"
  type        = string
  default     = ""
}

variable "use_secrets_manager" {
  description = "Whether to use AWS Secrets Manager for database credentials"
  type        = bool
  default     = true
}

# Flyway Configuration
variable "flyway_image" {
  description = "Docker image for Flyway"
  type        = string
  default     = "flyway/flyway:latest"
}

variable "flyway_cpu" {
  description = "CPU units for Flyway task"
  type        = string
  default     = "512"
}

variable "flyway_memory" {
  description = "Memory for Flyway task"
  type        = string
  default     = "1024"
}

# ECS Configuration
variable "ecs_cluster_name" {
  description = "Name of the ECS cluster (if empty, will create one)"
  type        = string
  default     = ""
}

variable "ecs_cluster_id" {
  description = "ID of existing ECS cluster (if provided, will not create a new one)"
  type        = string
  default     = ""
}

# IAM Configuration
variable "execution_role_arn" {
  description = "ARN of existing ECS task execution role (if empty, will create one)"
  type        = string
  default     = ""
}

variable "task_role_arn" {
  description = "ARN of existing ECS task role (if empty, will create one)"
  type        = string
  default     = ""
}

# Networking Configuration
variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for ECS tasks"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether to assign public IP to ECS tasks"
  type        = bool
  default     = false
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Advanced Configuration
variable "flyway_connect_retries" {
  description = "Number of connection retries for Flyway"
  type        = string
  default     = "2"
}

variable "flyway_group" {
  description = "Whether to enable Flyway group execution"
  type        = string
  default     = "true"
}

variable "max_run_attempts" {
  description = "Maximum attempts to run the Flyway task"
  type        = number
  default     = 5
}

variable "enable_logging" {
  description = "Enable CloudWatch logging for Flyway tasks"
  type        = bool
  default     = true
}