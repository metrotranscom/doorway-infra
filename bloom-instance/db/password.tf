
# Generate a random password if one has not been provided
resource "random_password" "password" {
  count  = local.generate_password ? 1 : 0
  length = local.pass_len
}

resource "aws_secretsmanager_secret" "conn_string" {
  name = "${local.name_prefix}-db"
}

# Store the password and the full connection string in a secret
resource "aws_secretsmanager_secret_version" "conn_string" {
  secret_id     = aws_secretsmanager_secret.conn_string.id
  secret_string = local.conn_string
}
