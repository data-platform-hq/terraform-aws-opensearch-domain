data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_opensearch_domain" "this" {
  count            = var.create ? 1 : 0
  domain_name      = var.domain_name
  engine_version   = var.engine_version
  advanced_options = var.advanced_options
  tags             = var.tags

  cluster_config {
    dynamic "cold_storage_options" {
      for_each = var.cluster_config.cold_storage_options_enabled ? [1] : []
      content {
        enabled = true
      }
    }
    dedicated_master_enabled = var.cluster_config.dedicated_master_enabled
    dedicated_master_count   = var.cluster_config.dedicated_master_enabled ? var.cluster_config.dedicated_master_count : null
    dedicated_master_type    = var.cluster_config.dedicated_master_enabled ? var.cluster_config.dedicated_master_type : null
    instance_count           = var.cluster_config.instance_count
    instance_type            = var.cluster_config.instance_type
    warm_enabled             = var.cluster_config.warm_enabled
    warm_count               = var.cluster_config.warm_enabled ? var.cluster_config.warm_count : null
    warm_type                = var.cluster_config.warm_enabled ? var.cluster_config.warm_type : null
    zone_awareness_enabled   = (var.cluster_config.availability_zones > 1) ? true : false
    dynamic "zone_awareness_config" {
      for_each = (var.cluster_config.availability_zones > 1) ? [var.cluster_config.availability_zones] : []
      content {
        availability_zone_count = zone_awareness_config.value
      }
    }
  }

  domain_endpoint_options {
    enforce_https       = var.domain_endpoint_enforce_https
    tls_security_policy = var.domain_endpoint_tls_security_policy

    custom_endpoint_enabled         = var.domain_endpoint_custom_endpoint_enabled
    custom_endpoint                 = var.domain_endpoint_custom_endpoint_enabled ? var.domain_endpoint_custom_endpoint : null
    custom_endpoint_certificate_arn = var.domain_endpoint_custom_endpoint_enabled ? var.domain_endpoint_custom_endpoint_certificate_arn : null
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption_enabled
  }

  dynamic "vpc_options" {
    for_each = var.vpc_enabled ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  dynamic "ebs_options" {
    for_each = var.ebs_enabled ? [1] : []
    content {
      ebs_enabled = true
      iops        = var.ebs_iops
      throughput  = var.ebs_throughput
      volume_size = var.ebs_volume_size
      volume_type = var.ebs_volume_type
    }
  }

  dynamic "encrypt_at_rest" {
    for_each = var.encrypt_at_rest_enabled ? [1] : []
    content {
      enabled    = true
      kms_key_id = var.encrypt_at_rest_kms_key_id
    }
  }

  dynamic "log_publishing_options" {
    for_each = var.log_publishing_options
    content {
      enabled                  = log_publishing_options.value.enabled
      cloudwatch_log_group_arn = log_publishing_options.value.cloudwatch_log_group_arn
      log_type                 = log_publishing_options.value.log_type
    }
  }

  dynamic "cognito_options" {
    for_each = var.cognito_options_enabled ? [1] : []
    content {
      enabled          = true
      identity_pool_id = var.cognito_options.identity_pool_id
      role_arn         = var.cognito_options.role_arn
      user_pool_id     = var.cognito_options.user_pool_id
    }
  }

  dynamic "advanced_security_options" {
    for_each = var.advanced_security_options_enabled ? [1] : []
    content {
      enabled                        = true
      anonymous_auth_enabled         = var.advanced_security_options.anonymous_auth_enabled
      internal_user_database_enabled = var.advanced_security_options.internal_user_database_enabled
      master_user_options {
        master_user_arn      = var.advanced_security_options.internal_user_database_enabled ? null : var.advanced_security_options.master_user_arn
        master_user_name     = var.advanced_security_options.internal_user_database_enabled ? var.advanced_security_options.master_user_name : null
        master_user_password = var.advanced_security_options.internal_user_database_enabled ? var.advanced_security_options.master_user_password : null
      }
    }
  }

  dynamic "auto_tune_options" {
    for_each = var.auto_tune_options_enabled && var.auto_tune_options_rollback_on_disable == "DEFAULT_ROLLBACK" ? [1] : []
    content {
      desired_state       = "ENABLED"
      rollback_on_disable = var.auto_tune_options_rollback_on_disable
      maintenance_schedule {
        cron_expression_for_recurrence = var.auto_tune_options_maintenance_schedule_cron_expression
        start_at                       = var.auto_tune_options_maintenance_schedule_start_at
        duration {
          unit  = "HOURS"
          value = var.auto_tune_options_maintenance_schedule_duration_value
        }
      }
    }
  }

  dynamic "auto_tune_options" {
    for_each = var.auto_tune_options_enabled && var.auto_tune_options_rollback_on_disable != "DEFAULT_ROLLBACK" ? [1] : []
    content {
      desired_state       = "ENABLED"
      rollback_on_disable = var.auto_tune_options_rollback_on_disable
    }
  }
}

resource "aws_opensearch_domain_saml_options" "this" {
  count       = var.create && var.saml_enabled ? 1 : 0
  domain_name = aws_opensearch_domain.this[0].domain_name
  saml_options {
    enabled = true
    idp {
      entity_id        = var.saml_config.idp_entity_id
      metadata_content = var.saml_config.idp_metadata_content
    }
    master_backend_role     = var.saml_config.master_backend_role
    master_user_name        = var.saml_config.master_user_name
    roles_key               = var.saml_config.roles_key
    session_timeout_minutes = var.saml_config.session_timeout_minutes
    subject_key             = var.saml_config.subject_key
  }
}

data "aws_iam_policy_document" "this" {
  count = var.create && var.domain_policy.enabled ? 1 : 0
  statement {
    effect      = "Allow"
    resources   = ["arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"]
    actions     = var.domain_policy.actions
    not_actions = var.domain_policy.not_actions
    dynamic "principals" {
      for_each = var.domain_policy.principals
      content {
        type        = principals.value.type
        identifiers = principals.value.identifiers
      }
    }
    dynamic "condition" {
      for_each = var.domain_policy.conditions
      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}

resource "aws_opensearch_domain_policy" "this" {
  count           = var.create && var.domain_policy.enabled ? 1 : 0
  domain_name     = aws_opensearch_domain.this[0].domain_name
  access_policies = data.aws_iam_policy_document.this[0].json
}

resource "aws_opensearch_outbound_connection" "this" {
  for_each = {
    for k, v in var.inbound_outbound_connections_config :
    v.domain_name => v if var.create && (v.outbound_connection_enabled || v.inbound_connection_accepter_enabled)
  }
  connection_alias = "${each.value.domain_name}-outbound-connection"
  local_domain_info {
    owner_id    = data.aws_caller_identity.current.account_id
    region      = data.aws_region.current.name
    domain_name = aws_opensearch_domain.this[0].domain_name
  }

  remote_domain_info {
    owner_id    = each.value.owner_id
    region      = each.value.region
    domain_name = each.value.domain_name
  }
}

resource "aws_opensearch_inbound_connection_accepter" "this" {
  for_each = {
    for k, v in var.inbound_outbound_connections_config :
    v.domain_name => v if var.create && v.inbound_connection_accepter_enabled
  }
  connection_id = aws_opensearch_outbound_connection.this[each.value.domain_name].id
}
