resource "aws_secretsmanager_secret" "this" {
  name                    = var.name
  description             = var.description
  recovery_window_in_days = var.recovery_window_in_days
  kms_key_id              = var.kms_key_id # null uses AWS managed key (aws/secretsmanager)
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = "{}"

  # ignore changes to everything because once we've created the secret and set the value
  # to "{}" we don't need to worry about it any more
  lifecycle {
    ignore_changes = [
      id,
      secret_id,
      secret_string,
      version_stages
    ]
  }
}

data "aws_iam_policy_document" "management" {
  statement {
    sid    = "AllowCurrentUserAndRootManagement"
    effect = "Allow"
    actions = [
      "secretsmanager:*"
    ]
    resources = [aws_secretsmanager_secret.this.arn]

    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/InfrastructureDeployer"
      ]
      type = "AWS"
    }

  }
}

data "aws_iam_policy_document" "this" {
  source_policy_documents = var.policy != null ? [
    data.aws_iam_policy_document.management.json,
    var.policy
    ] : [
    data.aws_iam_policy_document.management.json
  ]
}

resource "aws_secretsmanager_secret_policy" "this" {
  secret_arn = aws_secretsmanager_secret.this.arn
  policy     = data.aws_iam_policy_document.this.json
}