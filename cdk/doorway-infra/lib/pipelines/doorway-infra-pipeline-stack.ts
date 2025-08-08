import { Aws, Fn, Stack, StackProps, Stage, StageProps } from "aws-cdk-lib";
import {
  PolicyDocument,
  PolicyStatement,
  Role,
  ServicePrincipal,
} from "aws-cdk-lib/aws-iam";
import { Secret } from "aws-cdk-lib/aws-secretsmanager";
import {
  CodeBuildStep,
  CodePipeline,
  CodePipelineSource,
} from "aws-cdk-lib/pipelines";

import { SecurityGroup, Subnet, Vpc } from "aws-cdk-lib/aws-ec2";
import { Construct } from "constructs";
import { DoorwayDatabaseServerStack } from "../doorway-database-server-stack";
import { DoorwayEcsClusterStack } from "../doorway-ecs-cluster";
import { DoorwayGlobalResourcesStack } from "../doorway-global-resources-stack";
import { DoorwayNetworkStack } from "../doorway-network-stack";
import { DoorwayParametersStack } from "../doorway-parameters-stack";
import { DoorwayApiServiceStack } from "../doorway_api_service-stack";
export interface PipelineProps extends StackProps {
  githubSecret: string;
  dockerHubSecret: string;
}
export class DoorwayInfraPipelineStack extends Stack {
  constructor(scope: any, id: string, props: PipelineProps) {
    super(scope, id, {
      ...props,
      env: {
        account: process.env.CDK_DEFAULT_ACCOUNT,
        region: process.env.CDK_DEFAULT_REGION || "us-west-2",
      },
    });

    const pipelineRole = new Role(this, "doorway-app-pipeline-role", {
      assumedBy: new ServicePrincipal("codepipeline.amazonaws.com"),
    });
    pipelineRole.addToPolicy(
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
    );
    const githubSecret = Secret.fromSecretNameV2(
      this,
      "githubSecret",
      props.githubSecret,
    );

    const source = CodePipelineSource.gitHub(
      "metrotranscom/doorway-infra",
      "feat/new_cdk",
      {
        authentication: githubSecret.secretValue,
      },
    );
    const config = CodePipelineSource.gitHub(
      "metrotranscom/doorway-config",
      "main",
      {
        authentication: githubSecret.secretValue,
      },
    );

    const pipeline = new CodePipeline(this, "Doorway-Infra-Pipeline", {
      pipelineName: "doorway-infra-pipeline",
      selfMutation: true,
      role: pipelineRole,
      synth: new CodeBuildStep("Synth", {
        input: source,
        additionalInputs: {
          "../config": config,
        },
        commands: [
          "cd ${CODEBUILD_SRC_DIR}/cdk/doorway-infra",
          "npm install",
          "npm run build",
          "npx cdk synth",
        ],
        primaryOutputDirectory: "cdk/doorway-infra/cdk.out",
        rolePolicyStatements: [
          new PolicyStatement({
            actions: ["cloudformation:*", "ec2:*", "ssm:*"],
            resources: ["*"],
          }),
        ],
      }),
    });

    pipeline.addStage(
      new DoorwayGlobalStage(this, "DoorwayGlobalStage", {
        env: {
          account: process.env.CDK_DEFAULT_ACCOUNT || "no-account",
          region: process.env.CDK_DEFAULT_REGION || "no-region",
        },
      }),
    );
    const devBaseStage = new DoorwayEnvironmentBaseStage(
      this,
      `DoorwayEnvironmentBaseStage-Dev`,
      {
        env: {
          account: process.env.CDK_DEFAULT_ACCOUNT || "no-account",
          region: process.env.CDK_DEFAULT_REGION || "no-region",
        },
      },
      "dev2",
    );

    const devStageWithActions = pipeline.addStage(devBaseStage);

    const vpcId = Fn.importValue(`doorway-vpc-id-dev2`);
    const subnetId = Fn.importValue(`doorway-app-subnet-1-dev2`);
    const securityGroupId = Fn.importValue(`doorway-app-sg-dev2`);
    const dbSecretArn = Fn.importValue(`doorwayDBSecret-dev2`);
    const dbSecret = Secret.fromSecretCompleteArn(
      this,
      "dbSecret",
      dbSecretArn,
    );
    const vpc = Vpc.fromVpcAttributes(this, "vpc", {
      vpcId: vpcId,
      availabilityZones: Fn.importValue(`doorway-azs-dev2`).split(", "),
    });
    const subnet = Subnet.fromSubnetAttributes(this, "subnet", {
      subnetId: subnetId,
    });
    const sg = SecurityGroup.fromSecurityGroupId(this, "sg", securityGroupId);
    const buildRole = new Role(this, "doorway-app-build-role", {
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
                `arn:aws:ecr:${this.region}:${this.account}:repository/*`,
              ],
            }),
            new PolicyStatement({
              actions: ["secretsmanager:GetSecretValue"],
              resources: [githubSecret.secretArn],
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

    // Add a post-deployment CodeBuild step
    devStageWithActions.addPost(
      new CodeBuildStep("PostDeploymentTasks", {
        projectName: "DatabaseMigration",
        role: buildRole,
        env: {
          DB_SECRET_ARN: dbSecretArn,
          ECR_REGION: Aws.REGION,
          ECR_ACCOUNT_ID: Aws.ACCOUNT_ID,
          ECR_NAMESPACE: "doorway",
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
          'docker pull "${MIGRATION_IMAGE}"',
          'export MIGRATION_CMD="${MIGRATION_CMD:-db:migration:run}"',

          'docker run --env PGUSER="${PGUSER}" --env PGPASSWORD="${PGPASSWORD}" --env PGHOST="${PGHOST}" --env PGDATABASE="${PGDATABASE}" --env PGPORT="${PGPORT}" --env MIGRATION_CMD="${MIGRATION_CMD}" "${MIGRATION_IMAGE}"',
        ],

        vpc: vpc,
        securityGroups: [sg],
        subnetSelection: { subnets: [subnet] },
        buildEnvironment: {
          privileged: true,
        },
        rolePolicyStatements: [
          new PolicyStatement({
            actions: [
              "ecs:*",
              "ssm:*",
              "rds:*",
              "secretsmanager:GetSecretValue",
            ],
            resources: ["*"],
          }),
        ],
      }),
    );

    // const devStage = pipeline.addStage(
    //   new DoorwayEnvironmentStage(
    //     this,
    //     "DoorwayDevEnvironmentStage",
    //     props,
    //     "dev2",
    //   ),
    // );
    //

    // Add a pre-deployment step
  }
}
class DoorwayGlobalStage extends Stage {
  constructor(scope: Construct, id: string, props?: StageProps) {
    super(scope, id, props);
    new DoorwayGlobalResourcesStack(this, "DoorwayGlobalResourcesStack");
  }
}
class DoorwayEnvironmentStage extends Stage {
  constructor(
    scope: Construct,
    id: string,
    props?: StageProps,
    environment: string = "dev",
  ) {
    super(scope, id, props);

    const apiServiceStack = new DoorwayApiServiceStack(
      this,
      "DoorwayApiServiceStack",
      {
        environment: environment,
        env: {
          account: process.env.CDK_DEFAULT_ACCOUNT || "no-account",
          region: process.env.CDK_DEFAULT_REGION || "no-region",
        },
      },
    );
  }
}
class DoorwayEnvironmentBaseStage extends Stage {
  constructor(
    scope: Construct,
    id: string,
    props?: StageProps,
    environment: string = "dev",
  ) {
    super(scope, id, props);
    const networkstack = new DoorwayNetworkStack(this, "DoorwayNetworkStack", {
      environment: environment,
      env: {
        account: process.env.CDK_DEFAULT_ACCOUNT || "no-account",
        region: process.env.CDK_DEFAULT_REGION || "no-region",
      },
    });
    const parametersStack = new DoorwayParametersStack(
      this,
      "DoorwayParametersStack",
      {
        environment: environment,
        env: {
          account: process.env.CDK_DEFAULT_ACCOUNT || "no-account",
          region: process.env.CDK_DEFAULT_REGION || "no-region",
        },
      },
    );
    const dbstack = new DoorwayDatabaseServerStack(
      this,
      "DoorwayDatabaseServerStack",
      {
        environment: environment,
        env: {
          account: process.env.CDK_DEFAULT_ACCOUNT || "no-account",
          region: process.env.CDK_DEFAULT_REGION || "no-region",
        },
      },
    );
    dbstack.addDependency(networkstack);
    const ecsClusterStack = new DoorwayEcsClusterStack(
      this,
      "DoorwayEcsClusterStack",
      {
        environment: environment,
        env: {
          account: process.env.CDK_DEFAULT_ACCOUNT || "no-account",
          region: process.env.CDK_DEFAULT_REGION || "no-region",
        },
      },
    );
    ecsClusterStack.addDependency(networkstack);
  }
}
