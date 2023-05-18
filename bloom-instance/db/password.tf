
# Generate a random password if one has not been provided
resource "random_password" "password" {
  count   = local.generate_password ? 1 : 0
  length  = local.pass_len
  special = false # RDS is picky about special characters and the wrong ones can break the connection string
}

resource "aws_secretsmanager_secret" "conn_string" {
  name_prefix = "${local.name_prefix}/db/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableSecretRetrieval"
        Principal = "*" # Allow anyone with the right IAM permissions to read the secret
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = "*",
      }
    ]
  })
}

# Store the password and the full connection string in a secret
resource "aws_secretsmanager_secret_version" "conn_string" {
  secret_id = aws_secretsmanager_secret.conn_string.id
  secret_string = jsonencode({
    "uri" : local.conn_string,
    "user" : local.db.username,
    "password" : local.password,
    "host" : local.db.host,
    "db_name" : local.db.db_name,
    "port" : local.db.port
  })
}
