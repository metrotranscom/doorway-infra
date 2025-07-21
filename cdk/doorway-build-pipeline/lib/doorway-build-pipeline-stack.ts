import { Stack, StackProps } from "aws-cdk-lib";
import { PipelineProject } from "aws-cdk-lib/aws-codebuild";
import { Artifact, Pipeline } from "aws-cdk-lib/aws-codepipeline";
import {
  CodeBuildAction,
  GitHubSourceAction,
} from "aws-cdk-lib/aws-codepipeline-actions";
import { PolicyStatement, Role, ServicePrincipal } from "aws-cdk-lib/aws-iam";
import { Secret } from "aws-cdk-lib/aws-secretsmanager";
import * as fs from "fs";
import YAML from "yaml";

import { Construct } from "constructs";
export class DoorwayBuildPipelineStack extends Stack {
  constructor(scope: Construct, id: string, props: PipelineProps) {
    super(scope, id, props);
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
    const backendBuildspec = YAML.parse(
      fs.readFileSync("./buildspec/backend.yaml", "utf8"),
    );
    const githubSecret = Secret.fromSecretNameV2(
      this,
      "githubSecret",
      props.githubSecret,
    ).secretValue;
    const pipeline = new Pipeline(this, "doorway-app-pipeline", {
      role: pipelineRole,
      pipelineName: "doorway-app-pipeline",
    });
    const sourceArtifact = new Artifact("SourceArtifact");
    const doorwaySource = new GitHubSourceAction({
      actionName: "Source",
      oauthToken: githubSecret,
      owner: "metrotranscom",
      repo: "doorway",
      branch: "main",
      output: sourceArtifact,
    });

    const sourceStage = pipeline.addStage({
      stageName: "Source",
      actions: [doorwaySource],
    });
    const buildArtifact = new Artifact("BuildOutput");

    const buildAction = new CodeBuildAction({
      actionName: "Build",
      input: sourceArtifact,
      outputs: [buildArtifact],
      project: new PipelineProject(this, "doorway-app-build-project", {
        buildSpec: backendBuildspec,
        environmentVariables: {
          ECR_REGION: { value: this.region },
          ECR_ACCOUNT_ID: { value: this.account },
          ECR_REPO_NAME: { value: "doorway" },
        },

        role: new Role(this, "doorway-app-build-role", {
          assumedBy: new ServicePrincipal("codebuild.amazonaws.com"),
          managedPolicies: [
            {
              managedPolicyArn:
                "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
            },
            { managedPolicyArn: "arn:aws:iam::aws:policy/AmazonS3FullAccess" },
          ],
        }),
      }),
    });
    const buildStage = pipeline.addStage({
      stageName: "Build",
      actions: [buildAction],
    });
  }
}
export interface PipelineProps extends StackProps {
  githubSecret: string;
  dockerHubSecret: string;
}
