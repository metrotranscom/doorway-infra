import { Stack, StackProps, Stage, StageProps } from "aws-cdk-lib";
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
import * as fs from "fs";
import * as yaml from "yaml";

import { Construct } from "constructs";
import { DoorwayDatabaseServerStack } from "../doorway-database-server-stack";
import { DoorwayEcsClusterStack } from "../doorway-ecs-cluster";
import { DoorwayGlobalResourcesStack } from "../doorway-global-resources-stack";
import { DoorwayNetworkStack } from "../doorway-network-stack";
import { DoorwayParametersStack } from "../doorway-parameters-stack";
import { DoorwayApiServiceStack } from "../doorway_api_service-stack";
export interface PipelineProps extends StackProps {
  githubSecret: string;
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
              actions: [
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchCheckLayerAvailability",
              ],
              resources: [
                `arn:aws:ecr:${this.region}:${this.account}:repository/*`,
              ],
            }),
            new PolicyStatement({
              actions: ["secretsmanager:GetSecretValue"],
              resources: [
                `arn:aws:secretsmanager:${this.region}:${this.account}:secret:mtc/dockerHub*`,
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
    const githubSecret = Secret.fromSecretNameV2(
      this,
      "githubSecret",
      props.githubSecret,
    ).secretValue;
    const source = CodePipelineSource.gitHub(
      "metrotranscom/doorway-infra",
      "feat/new_cdk",
      {
        authentication: githubSecret,
      },
    );
    const config = CodePipelineSource.gitHub(
      "metrotranscom/doorway-config",
      "main",
      {
        authentication: githubSecret,
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

    // Read buildspec and convert to commands
    const buildspecPath = "./buildspec/post-deploy.yaml"; // Adjust path as needed
    let commands: string[] = [];

    try {
      const buildspecContent = yaml.parse(
        fs.readFileSync(buildspecPath, "utf8"),
      );

      // Extract commands from buildspec phases
      if (buildspecContent.phases) {
        Object.keys(buildspecContent.phases).forEach((phase) => {
          if (buildspecContent.phases[phase].commands) {
            commands.push(`echo "Phase: ${phase}"`);
            commands.push(...buildspecContent.phases[phase].commands);
          }
        });
      }
    } catch (error) {
      // Fallback to default commands if buildspec doesn't exist
      commands = [
        "echo 'Running post-deployment tasks'",
        "# Add your specific commands here",
      ];
    }

    // Add a post-deployment CodeBuild step
    devStageWithActions.addPost(
      new CodeBuildStep("PostDeploymentTasks", {
        input: source,
        env: {
          ENVIRONMENT: "dev2",
          DB_SECRET_ARN: `arn:aws:secretsmanager:${this.region}:${this.account}:secret:doorwayDBSecret-dev2*`,
        },
        commands: commands,
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
