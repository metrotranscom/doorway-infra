import { Fn, Stack } from "aws-cdk-lib";
import { BuildSpec, PipelineProject } from "aws-cdk-lib/aws-codebuild";
import { Artifact } from "aws-cdk-lib/aws-codepipeline";
import { CodeBuildAction } from "aws-cdk-lib/aws-codepipeline-actions";
import { SecurityGroup, Subnet, Vpc } from "aws-cdk-lib/aws-ec2";
import {
  PolicyDocument,
  PolicyStatement,
  Role,
  ServicePrincipal,
} from "aws-cdk-lib/aws-iam";
// Removed fs and YAML imports since we're using BuildSpec.fromSourceFilename

export interface DoorwayDatabaseMigrateProps {
  buildspec: string;

  source: Artifact;
  environment: string;
}

export class DoorwayDatabaseMigrate {
  public readonly action: CodeBuildAction;

  constructor(stack: Stack, id: string, props: DoorwayDatabaseMigrateProps) {
    const role = new Role(stack, `${id}-doorway-app-build-role`, {
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
              actions: [
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchCheckLayerAvailability",
              ],
              resources: [
                `arn:aws:ecr:${stack.region}:${stack.account}:repository/*`,
              ],
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
    const secretArn = Fn.importValue(`doorwayDBSecret-${props.environment}`);
    role.addToPolicy(
      new PolicyStatement({
        actions: ["secretsmanager:GetSecretValue"],
        resources: [secretArn],
      }),
    );
    const vpcId = Fn.importValue(`doorway-vpc-id-${props.environment}`);
    const appSubnetId = Fn.importValue(
      `doorway-app-subnet-1-${props.environment}`,
    );
    const appSubnet = Subnet.fromSubnetAttributes(stack, `${id}-AppSubnet`, {
      subnetId: appSubnetId,
    });

    const azs = Fn.importValue(`doorway-azs-${props.environment}`);
    const vpc = Vpc.fromVpcAttributes(stack, `${id}-Vpc`, {
      vpcId: vpcId,
      availabilityZones: azs.split(", "),

      privateSubnetIds: [appSubnetId],
    });
    const sgId = Fn.importValue(`doorway-app-sg-${props.environment}`);
    const sg = SecurityGroup.fromSecurityGroupId(
      stack,
      `default-security-group-${props.environment}`,
      sgId,
    );

    // Create the CodeBuild project
    const project = new PipelineProject(stack, `${id}-Project`, {
      vpc: vpc,
      securityGroups: [sg],
      subnetSelection: {
        subnets: [appSubnet],
      },

      buildSpec: BuildSpec.fromSourceFilename(props.buildspec),
      environmentVariables: {
        ECR_REGION: { value: stack.region },
        ECR_ACCOUNT_ID: { value: stack.account },
        ECR_NAMESPACE: { value: "doorway" },
        DB_CREDS_ARN: { value: secretArn },
      },
      role: role,
    });
    // Create the CodeBuild action
    this.action = new CodeBuildAction({
      actionName: `${id}-DBMigrate`,
      input: props.source,
      outputs: [new Artifact(`${id}-BuildOutput`)],
      project,
    });
  }
}
