# OpenTofu AWS Secrets Manager

OpenTofu module for creating AWS Secrets Manager secrets with configurable resource policies.

## Usage

```hcl
module "my_secret" {
  source = "git::https://github.com/im5tu/opentofu-aws-secrets-manager.git?ref=<commit sha>"

  name        = "my-application/api-key"
  description = "API key for my application"
}
```

### With custom policy

```hcl
data "aws_iam_policy_document" "read_access" {
  statement {
    sid    = "AllowLambdaRead"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123456789012:role/MyLambdaRole"]
    }
  }
}

module "my_secret" {
  source = "git::https://github.com/im5tu/opentofu-aws-secrets-manager.git?ref=<commit sha>"

  name        = "my-application/api-key"
  description = "API key for my application"
  policy      = data.aws_iam_policy_document.read_access.json
}
```

### With custom KMS key and role name

```hcl
module "my_secret" {
  source = "git::https://github.com/im5tu/opentofu-aws-secrets-manager.git?ref=<commit sha>"

  name                     = "my-application/api-key"
  description              = "API key for my application"
  kms_key_id               = aws_kms_key.secrets.arn
  infrastructure_role_name = "MyDeployerRole"
}
```

### With automatic rotation

```hcl
module "my_secret" {
  source = "git::https://github.com/im5tu/opentofu-aws-secrets-manager.git?ref=<commit sha>"

  name                = "my-application/db-credentials"
  description         = "Database credentials with automatic rotation"
  rotation_lambda_arn = aws_lambda_function.rotate_secret.arn
  rotation_days       = 30
}
```

## Requirements

| Name | Version |
|------|---------|
| opentofu | >= 1.9 |
| aws | ~> 6 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the secret | `string` | n/a | yes |
| description | The description of the secret to show inside of AWS console | `string` | `""` | no |
| recovery_window_in_days | The window before the secret is deleted (7-30 days) | `number` | `7` | no |
| policy | The policy to apply in addition to the management policy | `string` | `null` | no |
| kms_key_id | The KMS key to secure the secrets (uses AWS managed key if not provided) | `string` | `null` | no |
| infrastructure_role_name | The name of the IAM role that can manage secrets | `string` | `"InfrastructureDeployer"` | no |
| rotation_lambda_arn | The ARN of the Lambda that rotates the secret (enables rotation when provided) | `string` | `null` | no |
| rotation_days | The number of days between automatic scheduled rotations (1-365) | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| name | The name of the secret |
| arn | The ARN of the secret |

## Development

### Validation

This module uses GitHub Actions for validation:

- **Format check**: `tofu fmt -check -recursive`
- **Validation**: `tofu validate`
- **Security scanning**: Checkov, Trivy

### Local Development

```bash
# Format code
tofu fmt -recursive

# Validate
tofu init -backend=false
tofu validate
```

## License

MIT License - see [LICENSE](LICENSE) for details.
