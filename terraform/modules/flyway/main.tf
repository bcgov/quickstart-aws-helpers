locals {
  # Determine if we need to create ECS cluster
  create_ecs_cluster = var.ecs_cluster_id == "" && var.ecs_cluster_name == ""

  # Determine cluster name and ID
  cluster_name = local.create_ecs_cluster ? var.app_name : (var.ecs_cluster_name != "" ? var.ecs_cluster_name : null)
  cluster_id   = local.create_ecs_cluster ? aws_ecs_cluster.ecs_cluster[0].id : (var.ecs_cluster_id != "" ? var.ecs_cluster_id : data.aws_ecs_cluster.existing[0].id)

  # Determine if we need to create IAM roles
  create_execution_role = var.execution_role_arn == ""
  create_task_role      = var.task_role_arn == ""

  # Final role ARNs
  execution_role_arn = local.create_execution_role ? aws_iam_role.ecs_task_execution_role[0].arn : var.execution_role_arn
  task_role_arn      = local.create_task_role ? aws_iam_role.app_container_role[0].arn : var.task_role_arn
}

# Data sources for existing resources
data "aws_ecs_cluster" "existing" {
  count        = var.ecs_cluster_name != "" && var.ecs_cluster_id == "" ? 1 : 0
  cluster_name = var.ecs_cluster_name
}

# Try to fetch secrets manager secret, but don't fail if it doesn't exist
data "aws_secretsmanager_secret" "db_master_creds" {
  count = var.db_cluster_name != "" && var.use_secrets_manager ? 1 : 0
  name  = var.db_cluster_name
}

# Try to fetch RDS cluster, but don't fail if it doesn't exist
data "aws_rds_cluster" "rds_cluster" {
  count              = var.db_cluster_name != "" && var.db_host == "" ? 1 : 0
  cluster_identifier = var.db_cluster_name
}

# Try to fetch secret version, but don't fail if secret doesn't exist
data "aws_secretsmanager_secret_version" "db_master_creds_version" {
  count     = length(data.aws_secretsmanager_secret.db_master_creds) > 0 ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.db_master_creds[0].id
}

locals {
  # Use try() to safely access data sources with fallback values
  db_master_creds = var.use_secrets_manager ? try(
    jsondecode(data.aws_secretsmanager_secret_version.db_master_creds_version[0].secret_string),
    {
      username = var.db_username
      password = var.db_password
    }
    ) : {
    username = var.db_username
    password = var.db_password
  }

  # Provide database endpoint
  db_endpoint = var.db_host != "" ? var.db_host : try(
    data.aws_rds_cluster.rds_cluster[0].endpoint,
    "localhost"
  )

  # Flag to indicate if database resources are available
  db_resources_available = var.db_cluster_name != "" && (var.db_host != "" || length(data.aws_rds_cluster.rds_cluster) > 0)
}

# ECS Cluster (optional creation)
resource "aws_ecs_cluster" "ecs_cluster" {
  count = local.create_ecs_cluster ? 1 : 0
  name  = var.app_name
  tags  = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  count        = local.create_ecs_cluster ? 1 : 0
  cluster_name = aws_ecs_cluster.ecs_cluster[0].name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}

# Trigger for Flyway task recreation
resource "terraform_data" "trigger_flyway" {
  count = var.db_cluster_name != "" ? 1 : 0
  input = timestamp()
}

# ECS Task Execution Role (optional creation)
resource "aws_iam_role" "ecs_task_execution_role" {
  count = local.create_execution_role ? 1 : 0
  name  = "${var.app_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  count      = local.create_execution_role ? 1 : 0
  role       = aws_iam_role.ecs_task_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "app_container_role" {
  count = local.create_task_role ? 1 : 0
  name  = "${var.app_name}-app-container-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "secrets_manager_policy" {
  count = local.create_task_role && var.use_secrets_manager && var.db_cluster_name != "" ? 1 : 0
  name  = "${var.app_name}-secrets-manager-policy"
  role  = aws_iam_role.app_container_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:*:secret:${var.db_cluster_name}*"
      }
    ]
  })
}

# Flyway ECS Task Definition
resource "aws_ecs_task_definition" "flyway_task" {
  count                    = var.db_cluster_name != "" ? 1 : 0
  family                   = "${var.app_name}-flyway"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.flyway_cpu
  memory                   = var.flyway_memory
  execution_role_arn       = local.execution_role_arn
  task_role_arn            = local.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-flyway"
      image     = var.flyway_image
      essential = true
      environment = [
        {
          name  = "FLYWAY_URL"
          value = "jdbc:postgresql://${local.db_endpoint}/${var.db_name}?sslmode=require"
        },
        {
          name  = "FLYWAY_USER"
          value = local.db_master_creds.username
        },
        {
          name  = "FLYWAY_PASSWORD"
          value = local.db_master_creds.password
        },
        {
          name  = "FLYWAY_DEFAULT_SCHEMA"
          value = var.db_schema
        },
        {
          name  = "FLYWAY_CONNECT_RETRIES"
          value = var.flyway_connect_retries
        },
        {
          name  = "FLYWAY_GROUP"
          value = var.flyway_group
        }
      ]

      logConfiguration = var.enable_logging ? {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = "/ecs/${var.app_name}/flyway"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      } : null

      mountPoints = []
      volumesFrom = []
    }
  ])

  lifecycle {
    replace_triggered_by = [terraform_data.trigger_flyway[0]]
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOF
    set -euo pipefail

    max_attempts=${var.max_run_attempts}
    attempt=1
    task_arn=""
    while [[ $attempt -le $max_attempts ]]; do
      echo "Starting Flyway task (attempt $attempt)..."
      task_arn=$(aws ecs run-task \
        --task-definition ${var.app_name}-flyway \
        --cluster ${local.cluster_id} \
        --count 1 \
        --network-configuration "{\"awsvpcConfiguration\":{\"subnets\":[\"${join("\",\"", var.subnet_ids)}\"],\"securityGroups\":[\"${join("\",\"", var.security_group_ids)}\"],\"assignPublicIp\":\"${var.assign_public_ip ? "ENABLED" : "DISABLED"}\"}}" \
        --query 'tasks[0].taskArn' \
        --output text)

      if [[ -n "$task_arn" && "$task_arn" != "None" ]]; then
        echo "Flyway task started with ARN: $task_arn at $(date)."
        break
      fi
      echo "No task ARN returned. Retrying in 5 seconds..."
      sleep 5
      ((attempt++))
    done
    
    if [[ -z "$task_arn" || "$task_arn" == "None" ]]; then
      echo "ERROR: Failed to start ECS task after $max_attempts attempts."
      exit 1
    fi
    
    echo "Waiting for Flyway task to complete..."
    aws ecs wait tasks-stopped --cluster ${local.cluster_id} --tasks $task_arn
    
    echo "Flyway task completed, at $(date)."
    
    task_status=$(aws ecs describe-tasks --cluster ${local.cluster_id} --tasks $task_arn --query 'tasks[0].lastStatus' --output text)
    echo "Flyway task status: $task_status at $(date)."
    
    if [[ "${var.enable_logging}" == "true" ]]; then
      log_stream_name=$(aws logs describe-log-streams \
        --log-group-name "/ecs/${var.app_name}/flyway" \
        --order-by "LastEventTime" \
        --descending \
        --limit 1 \
        --query 'logStreams[0].logStreamName' \
        --output text)

      echo "Fetching logs from log stream: $log_stream_name"

      aws logs get-log-events \
        --log-group-name "/ecs/${var.app_name}/flyway" \
        --log-stream-name $log_stream_name \
        --limit 1000 \
        --no-cli-pager
    fi
    
    task_exit_code=$(aws ecs describe-tasks \
        --cluster ${local.cluster_id} \
        --tasks $task_arn \
        --query 'tasks[0].containers[0].exitCode' \
        --output text)

    if [ "$task_exit_code" != "0" ]; then
      echo "Flyway task failed with exit code: $task_exit_code"
      exit 1
    fi
  EOF
  }

  tags = var.tags
}