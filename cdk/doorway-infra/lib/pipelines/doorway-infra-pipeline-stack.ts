import { Stack, StackProps, Stage, StageProps } from "aws-cdk-lib";
import { PolicyStatement, Role, ServicePrincipal } from "aws-cdk-lib/aws-iam";
import { Secret } from "aws-cdk-lib/aws-secretsmanager";
import {
  CodeBuildStep,
  CodePipeline,
  CodePipelineSource,
} from "aws-cdk-lib/pipelines";

import { Construct } from "constructs";
import { DoorwayGlobalResourcesStack } from "../base_infra/doorway-global-resources-stack";
import { DoorwayEnvironmentBaseStage } from "./doorway-environment-base-stage";
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
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "sts:AssumeRole",
        ],
        resources: ["*"],
      }),
    );

    // Allow the pipeline role to assume itself and other pipeline roles
    pipelineRole.addToPolicy(
      new PolicyStatement({
        actions: ["sts:AssumeRole"],
        resources: [
          `arn:aws:iam::${this.account}:role/DoorwayInfraPipelineStack-*`,
          `arn:aws:iam::${this.account}:role/cdk-*`,
        ],
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
  }
}

class DoorwayGlobalStage extends Stage {
  constructor(scope: Construct, id: string, props?: StageProps) {
    super(scope, id, props);
    new DoorwayGlobalResourcesStack(this, "DoorwayGlobalResourcesStack");
  }
}
