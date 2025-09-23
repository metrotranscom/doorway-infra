#!/bin/bash
#Setting defaults for optional arguments
ECR_NAMESPACE="doorway"
PGDATABASE="bloom"
while getopts "a:d:m:r:n:s:h:" opt; do
	case ${opt} in
	a) ECR_ACCOUNT_ID="${OPTARG}" ;;
	d) PGDATABASE="${OPTARG}" ;;
	r) ECR_REGION="${OPTARG}" ;;
	n) ECR_NAMESPACE="${OPTARG}" ;;
	s) DB_CREDS_ARN="${OPTARG}" ;;
	m) MIGRATION_CMD="${OPTARG}" ;;
	h)
		echo "Usage: $0 -a <AWS_ACCOUNT_ID> -r <AWS_REGION>  -s <ARN for database Secret> -d <Database name (optional)> -n <ECR_NAMESPACE (Optional)> " >&2
		exit 0
		;;
	*)
		echo "Usage: $0 -a <AWS_ACCOUNT_ID> -r <AWS_REGION>  -s <ARN for database Secret> -d <Database name (optional)> -n <ECR_NAMESPACE (Optional)> " >&2
		exit 1
		;;
	esac
done
# trunk-ignore(shellcheck/SC2312)
PGUSER=$(aws secretsmanager get-secret-value --secret-id "${DB_CREDS_ARN}" --region "${ECR_REGION}" --query SecretString --output text | jq -r .username)
# trunk-ignore(shellcheck/SC2312)
PGPASSWORD=$(aws secretsmanager get-secret-value --secret-id "${DB_CREDS_ARN}" --region "${ECR_REGION}" --query SecretString --output text | jq -r .password)
# trunk-ignore(shellcheck/SC2312)
PGHOST=$(aws secretsmanager get-secret-value --secret-id "${DB_CREDS_ARN}" --region "${ECR_REGION}" --query SecretString --output text | jq -r .host)
# trunk-ignore(shellcheck/SC2312)
PGPORT=$(aws secretsmanager get-secret-value --secret-id "${DB_CREDS_ARN}" --region "${ECR_REGION}" --query SecretString --output text | jq -r .port)
# trunk-ignore(shellcheck/SC2312)
aws ecr get-login-password --region "${ECR_REGION}" | docker login --username AWS --password-stdin "${ECR_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com"
export ECR_REPO="${ECR_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${ECR_NAMESPACE}"
export MIGRATION_IMAGE="${ECR_REPO}/backend:migrate-candidate"
docker pull "${MIGRATION_IMAGE}"
# Default to db:migration:run
export MIGRATION_CMD="${MIGRATION_CMD:-db:migration:run}"

# Execute migration
# Note that many of these vars are required by the app but not used for migration
docker run \
	--env PGUSER="${PGUSER}" \
	--env PGPASSWORD="${PGPASSWORD}" \
	--env PGHOST="${PGHOST}" \
	--env PGDATABASE="${PGDATABASE}" \
	--env PGPORT="${PGPORT}" \
	--env MIGRATION_CMD="${MIGRATION_CMD}" \
	"${MIGRATION_IMAGE}"
