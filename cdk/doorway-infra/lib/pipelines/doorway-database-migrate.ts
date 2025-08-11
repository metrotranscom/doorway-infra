import { Aws, Fn, Stack } from "aws-cdk-lib";
import { SecurityGroup, Subnet, Vpc } from "aws-cdk-lib/aws-ec2";
import {
  PolicyDocument,
  PolicyStatement,
  Role,
  ServicePrincipal,
} from "aws-cdk-lib/aws-iam";
import { CodeBuildStep } from "aws-cdk-lib/pipelines";
// Removed fs and YAML imports since we're using BuildSpec.fromSourceFilename

export interface DoorwayDatabaseMigrateProps {
  ecrNamespace?: string;
  databaseName?: string;
  environment: string;
}

export class DoorwayDatabaseMigrate {
  public readonly step: CodeBuildStep;
  constructor(stack: Stack, id: string, props: DoorwayDatabaseMigrateProps) {
    const vpcId = Fn.importValue(`doorway-vpc-id-${props.environment}`);
    const subnetId = Fn.importValue(
      `doorway-app-subnet-1-${props.environment}`,
    );
    const securityGroupId = Fn.importValue(
      `doorway-app-sg-1-${props.environment}`,
    );
    const dbSecretArn = Fn.importValue(
      `doorwayDBSecret-arn-${props.environment}`,
    );
    const azs = Fn.importValue(`doorway-azs-${props.environment}`).split(", ");
    const vpc = Vpc.fromVpcAttributes(stack, "vpc", {
      vpcId: vpcId,
      availabilityZones: azs,
    });
    const subnet = Subnet.fromSubnetAttributes(stack, "subnet", {
      subnetId: subnetId,
    });
    const sg = SecurityGroup.fromSecurityGroupId(stack, "sg", securityGroupId);

    const buildRole = new Role(stack, "doorway-app-build-role", {
      assumedBy: new ServicePrincipal("codebuild.amazonaws.com"),
      managedPolicies: [
        {
          managedPolicyArn:
            "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
        },
        {
          managedPolicyArn: "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        },
      ],
      inlinePolicies: {
        ECRPolicies: new PolicyDocument({
          statements: [
            new PolicyStatement({
              actions: ["ecr:*"],
              resources: [
                `arn:aws:ecr:${Aws.REGION}:${Aws.ACCOUNT_ID}:repository/*`,
              ],
            }),
            new PolicyStatement({
              actions: ["secretsmanager:GetSecretValue"],
              resources: [dbSecretArn],
            }),
            new PolicyStatement({
              actions: [
                "cloudformation:*",
                "ec2:*",
                "ssm:*",
                "codebuild:*",
                "logs:*",
                "iam:AssumeRole",
                "iam:PassRole",
              ],
              resources: ["*"],
            }),
          ],
        }),
      },
    });
    this.step = new CodeBuildStep("PostDeploymentTasks", {
      projectName: "DatabaseMigration",
      role: buildRole,
      env: {
        DB_SECRET_ARN: dbSecretArn,
        ECR_REGION: Aws.REGION,
        ECR_ACCOUNT_ID: Aws.ACCOUNT_ID,
        ECR_NAMESPACE: props.ecrNamespace || "doorway",
        PG_DATABASE: props.databaseName || "bloom",
      },

      commands: [
        "echo 'Running database migration'",
        "# Get database credentials (secrets not logged)",
        "export DB_CREDS=$(aws secretsmanager get-secret-value --secret-id $DB_SECRET_ARN --query SecretString --output text 2>/dev/null)",
        "export PGHOST=$(echo $DB_CREDS | jq -r '.host' 2>/dev/null)",
        "export PGUSER=$(echo $DB_CREDS | jq -r '.username' 2>/dev/null)",
        "export PGPASSWORD=$(echo $DB_CREDS | jq -r '.password' 2>/dev/null)",
        "export PGPORT=$(echo $DB_CREDS | jq -r '.port' 2>/dev/null)",
        'aws ecr get-login-password --region "${ECR_REGION}" | docker login --username AWS --password-stdin "${ECR_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com"',
        'export ECR_REPO="${ECR_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${ECR_NAMESPACE}"',
        'export MIGRATION_IMAGE="${ECR_REPO}/backend:migrate-candidate"',
        'export MIGRATION_CMD="${MIGRATION_CMD:-db:reseed:ci}"',
        'docker pull "${MIGRATION_IMAGE}"',
        'export MIGRATION_CMD="${MIGRATION_CMD:-db:migration:run}"',
        `docker run --rm \
            --env PGUSER="$PGUSER" \
            --env PGPASSWORD="$PGPASSWORD" \
            --env PGHOST="$PGHOST" \
            --env PGDATABASE="$PG_DATABASE" \
            --env PGPORT="$PGPORT" \
            --env MIGRATION_CMD="$MIGRATION_CMD" \
            --env CLOUDINARY_CLOUD_NAME="not-used" \
            --env LISTINGS_QUERY="/listings" \
            --env FILE_SERVICE="cloudinary" \
            --env PORT="3100" \
            --env EMAIL_API_KEY="SG.dummy_value" \
            --env APP_SECRET="dummy-value-that-is-at-least-16-character-long" \
            --env CLOUDINARY_SECRET="dummy_secret" \
            --env CLOUDINARY_KEY="dummy_key" \
            --env ADMIN_ACCOUNTS="100" \
            --env PARTNERS_BASE_URL="http://localhost:3001/not-used" \
            --env PARTNERS_PORTAL_URL="http://localhost:3001/not-used" \
            --env SKIP_MIGRATIONS=FALSE \
            $MIGRATION_IMAGE`,
      ],

      vpc: vpc,
      securityGroups: [sg],
      subnetSelection: { subnets: [subnet] },
      buildEnvironment: {
        privileged: true,
      },
    });
  }
}
