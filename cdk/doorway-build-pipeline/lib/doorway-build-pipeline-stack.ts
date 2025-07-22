import { Stack, StackProps } from "aws-cdk-lib";
import { BuildSpec, PipelineProject } from "aws-cdk-lib/aws-codebuild";
import { Artifact, Pipeline } from "aws-cdk-lib/aws-codepipeline";
import {
  CodeBuildAction,
  GitHubSourceAction,
} from "aws-cdk-lib/aws-codepipeline-actions";
import { PolicyStatement, Role, ServicePrincipal } from "aws-cdk-lib/aws-iam";
import { Secret } from "aws-cdk-lib/aws-secretsmanager";
import * as fs from "fs";
import YAML from "yaml";

import { Repository } from "aws-cdk-lib/aws-ecr";
import { Construct } from "constructs";
export class DoorwayBuildPipelineStack extends Stack {
  constructor(scope: Construct, id: string, props: PipelineProps) {
    super(scope, id, props);
    const ecrRepository = new Repository(this, "doorway-ecr-repository", {
      repositoryName: "doorway/backend",
    });
    // No need to create a repository for docker-hub if using pull-through cache
    // The pull-through cache repository should already be configured in the AWS console

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
    const dockerSecret = Secret.fromSecretNameV2(
      this,
      "dockerSecret",
      props.dockerHubSecret,
    ).secretArn;

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
    const buildRole = new Role(this, "doorway-app-build-role", {
      assumedBy: new ServicePrincipal("codebuild.amazonaws.com"),

      managedPolicies: [
        {
          managedPolicyArn:
            "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
        },
        { managedPolicyArn: "arn:aws:iam::aws:policy/AmazonS3FullAccess" },
      ],
    });
    ecrRepository.grantPullPush(buildRole);

    // Add permissions to use the ECR pull-through cache
    // Add permissions for jq
    buildRole.addToPolicy(
      new PolicyStatement({
        actions: [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
        ],
        resources: [`arn:aws:ecr:${this.region}:${this.account}:repository/*`],
      }),
    );
    buildRole.addToPolicy(
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
    buildRole.addToPolicy(
      new PolicyStatement({
        actions: ["secretsmanager:GetSecretValue"],
        resources: [
          dockerSecret,
          `arn:aws:secretsmanager:${this.region}:${this.account}:secret:mtc/dockerHub*`,
        ],
      }),
    );

    const buildAction = new CodeBuildAction({
      actionName: "Build",
      input: sourceArtifact,
      outputs: [buildArtifact],
      project: new PipelineProject(this, "doorway-app-build-project", {
        buildSpec: BuildSpec.fromObject(backendBuildspec),
        environmentVariables: {
          ECR_REGION: { value: this.region },
          ECR_ACCOUNT_ID: { value: this.account },
          ECR_NAMESPACE: { value: "doorway" },
          DOCKER_HUB_SECRET_ARN: {
            value: `arn:aws:secretsmanager:${this.region}:${this.account}:secret:mtc/dockerHub`,
          },
        },

        role: buildRole,
      }),
    });
    const ecrServer = Repository.fromRepositoryName(
      this,
      "ecrServer",
      "mtc-core-ecr",
    );

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
