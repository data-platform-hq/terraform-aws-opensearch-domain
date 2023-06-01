variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# OpenSearch domain
################################################################################
variable "domain_name" {
  description = "Name of the OpenSearch domain"
  type        = string
}

variable "engine_version" {
  description = "Version of OpenSearch to deploy"
  type        = string
  default     = "OpenSearch_2.5"
}

variable "advanced_options" {
  description = "Key-value string pairs to specify advanced configuration options"
  type        = map(string)
  default     = {}
}

variable "advanced_security_options_enabled" {
  description = "Whether advanced security is enabled"
  type        = bool
  default     = false
}

variable "advanced_security_options_anonymous_auth_enabled" {
  description = "Whether Anonymous auth is enabled"
  type        = bool
  default     = false
}

variable "advanced_security_options_internal_user_database_enabled" {
  description = "Whether the internal user database is enabled"
  type        = bool
  default     = false
}

variable "advanced_security_options_master_user_arn" {
  description = "ARN for the main user. If not specified, then it defaults to using the IAM user that is making the request"
  type        = string
  default     = ""
}

variable "advanced_security_options_master_user_name" {
  description = "Main user's username, which is stored in the Amazon OpenSearch Service domain's internal database. Applicable if advanced_security_options_internal_user_database_enabled set to true"
  type        = string
  default     = ""
}

variable "advanced_security_options_master_user_password" {
  description = "Main user's password, which is stored in the Amazon OpenSearch Service domain's internal database. Applicable if advanced_security_options_internal_user_database_enabled set to true"
  type        = string
  default     = ""
}

variable "auto_tune_options_enabled" {
  description = "Whether auto tune options are enabled"
  type        = bool
  default     = false
}

variable "auto_tune_options_rollback_on_disable" {
  description = "Whether to roll back to default Auto-Tune settings when disabling Auto-Tune"
  type        = string
  default     = "NO_ROLLBACK"
}

variable "auto_tune_options_maintenance_schedule_cron_expression" {
  description = "A cron expression specifying the recurrence pattern for an Auto-Tune maintenance schedule"
  type        = string
  default     = ""
}

variable "auto_tune_options_maintenance_schedule_start_at" {
  description = "Date and time at which to start the Auto-Tune maintenance schedule in RFC3339 format"
  type        = string
  default     = ""
}

variable "auto_tune_options_maintenance_schedule_duration_value" {
  description = "An integer specifying the value of the duration of an Auto-Tune maintenance window"
  type        = number
  default     = 0
}

variable "cluster_config" {
  description = "Cluster configuration"
  type = object({
    cold_storage_options_enabled = optional(bool, false)
    dedicated_master_enabled     = optional(bool, true)
    dedicated_master_count       = optional(number, 3)
    dedicated_master_type        = optional(string, "m6g.large.search")
    instance_count               = optional(number, 3)
    instance_type                = optional(string, "r6g.large.search")
    warm_enabled                 = optional(bool, false)
    warm_count                   = optional(number, 2)
    warm_type                    = optional(string, "ultrawarm1.medium.search")
    availability_zones           = optional(number, 3)
  })
  default = {}
}

variable "cognito_options_enabled" {
  description = "Whether Amazon Cognito authentication with Kibana is enabled or not"
  type        = bool
  default     = false
}

variable "cognito_options" {
  description = "Configuration block for authenticating Kibana with Cognito"
  type = object({
    identity_pool_id = string
    role_arn         = string
    user_pool_id     = string
  })
  default = {
    identity_pool_id = ""
    role_arn         = ""
    user_pool_id     = ""
  }
}

variable "domain_endpoint_enforce_https" {
  description = "Whether or not to require HTTPS"
  type        = bool
  default     = true
}

variable "domain_endpoint_tls_security_policy" {
  description = "Name of the TLS security policy that needs to be applied to the HTTPS endpoint. Valid values: Policy-Min-TLS-1-0-2019-07 and Policy-Min-TLS-1-2-2019-07"
  type        = string
  default     = "Policy-Min-TLS-1-2-2019-07"
}

variable "domain_endpoint_custom_endpoint_enabled" {
  description = "Whether to enable custom endpoint for the OpenSearch domain"
  type        = bool
  default     = false
}

variable "domain_endpoint_custom_endpoint" {
  description = "Fully qualified domain for your custom endpoint"
  type        = string
  default     = ""
}

variable "domain_endpoint_custom_endpoint_certificate_arn" {
  description = "ACM certificate ARN for your custom endpoint"
  type        = string
  default     = ""
}

variable "ebs_enabled" {
  description = "Whether EBS volumes are attached to data nodes in the domain"
  type        = bool
  default     = false
}

variable "ebs_iops" {
  description = "Baseline input/output (I/O) performance of EBS volumes attached to data nodes. Applicable only for the GP3 and Provisioned IOPS EBS volume types"
  type        = number
  default     = 3000
}


variable "ebs_throughput" {
  description = "(Required if volume_type is set to gp3) Specifies the throughput (in MiB/s) of the EBS volumes attached to data nodes. Applicable only for the gp3 volume type"
  type        = number
  default     = 125
}


variable "ebs_volume_size" {
  description = "(Required if ebs_enabled is set to true.) Size of EBS volumes attached to data nodes (in GiB)"
  type        = number
  default     = 10
}


variable "ebs_volume_type" {
  description = "Type of EBS volumes attached to data nodes"
  type        = string
  default     = "gp3"
}

variable "encrypt_at_rest_enabled" {
  description = "Whether to enable encryption at rest"
  type        = bool
  default     = true
}

variable "encrypt_at_rest_kms_key_id" {
  description = "KMS key ARN to encrypt the OpenSearch domain with"
  type        = string
  default     = ""
}

variable "log_publishing_options" {
  description = "Configuration block for publishing slow and application logs to CloudWatch Logs"
  type = list(object({
    enabled                  = optional(bool, true)
    cloudwatch_log_group_arn = string
    log_type                 = string
  }))
  default = []
}

variable "node_to_node_encryption_enabled" {
  description = "Whether to enable node-to-node encryption"
  type        = bool
  default     = true
}

variable "vpc_enabled" {
  description = "Whether the cluster is running inside a VPC"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "The list of VPC subnet IDs to use"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "The list of VPC security groups IDs to attach"
  type        = list(string)
  default     = []
}

variable "saml_enabled" {
  description = "Whether SAML authentication is enabled"
  type        = bool
  default     = false
}

variable "saml_config" {
  description = "SAML config"
  type = object({
    idp_entity_id           = string
    idp_metadata_content    = string
    master_backend_role     = optional(string, null)
    master_user_name        = optional(string, null)
    roles_key               = optional(string, null)
    session_timeout_minutes = optional(number, null)
    subject_key             = optional(string, null)
  })
  default = {
    idp_entity_id        = ""
    idp_metadata_content = ""
  }
}

variable "domain_policy" {
  description = "Access policy for OpenSearch domain"
  type = object({
    enabled     = optional(bool, false)
    actions     = optional(list(string), ["es:*"])
    not_actions = optional(list(string), null)
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })), [])
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  })
  default = {}
}

variable "inbound_outbound_connections_config" {
  description = "Configuration for AWS Opensearch Outbound Connection & AWS Opensearch Inbound Connection Accepter"
  type = list(object({
    outbound_connection_enabled         = bool
    inbound_connection_accepter_enabled = bool
    owner_id                            = string
    region                              = string
    domain_name                         = string
  }))
  default = []
}
