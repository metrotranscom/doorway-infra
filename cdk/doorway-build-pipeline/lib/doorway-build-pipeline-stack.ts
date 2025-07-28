import { Stack, StackProps } from "aws-cdk-lib";
import { BuildSpec, PipelineProject } from "aws-cdk-lib/aws-codebuild";
import { Artifact, Pipeline } from "aws-cdk-lib/aws-codepipeline";
import {
  CodeBuildAction,
  GitHubSourceAction,
} from "aws-cdk-lib/aws-codepipeline-actions";
import { Repository } from "aws-cdk-lib/aws-ecr";
import {
  PolicyDocument,
  PolicyStatement,
  Role,
  ServicePrincipal,
} from "aws-cdk-lib/aws-iam";
import { Secret } from "aws-cdk-lib/aws-secretsmanager";
import { Construct } from "constructs";
import * as fs from "fs";
import YAML from "yaml";
export class DoorwayBuildPipelineStack extends Stack {
  constructor(scope: Construct, id: string, props: PipelineProps) {
    super(scope, id, props);

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
      branch: "fix/update_image_location",
      output: sourceArtifact,
    });
    const configSourceArtifact = new Artifact("ConfigSourceArtifact");
    const doorwayConfigSource = new GitHubSourceAction({
      actionName: "ConfigSource",
      oauthToken: githubSecret,
      owner: "metrotranscom",
      repo: "doorway-config",
      branch: "feat/cdk-terraform",
      output: configSourceArtifact,
    });

    const sourceStage = pipeline.addStage({
      stageName: "Source",
      actions: [doorwaySource, doorwayConfigSource],
    });
    const buildStage = pipeline.addStage({
      stageName: "Build",
      actions: [
        new DoorwayDockerBuild(this, `doorway-backend`, {
          buildspec: "./buildspec/build_backend.yml",
          imageName: "backend",
          source: sourceArtifact,
          configSource: configSourceArtifact,
          role: buildRole,
          dockerHubSecret: dockerSecret,
        }),
        new DoorwayDockerBuild(this, "doorway-import-listings", {
          buildspec: "./buildspec/build_import_listings.yml",
          imageName: "import-listings",
          source: sourceArtifact,
          configSource: configSourceArtifact,
          role: buildRole,
          dockerHubSecret: dockerSecret,
        }),
        new DoorwayDockerBuild(this, `doorway-partners`, {
          buildspec: "./buildspec/build_partners.yml",
          imageName: "partners",
          source: sourceArtifact,
          configSource: configSourceArtifact,
          role: buildRole,
          dockerHubSecret: dockerSecret,
        }),
        new DoorwayDockerBuild(this, "doorway-public", {
          buildspec: "./buildspec/build_public.yml",
          imageName: "public",
          source: sourceArtifact,
          configSource: configSourceArtifact,
          role: buildRole,
          dockerHubSecret: dockerSecret,
        }),
      ],
    });
  }
}
export interface PipelineProps extends StackProps {
  githubSecret: string;
  dockerHubSecret: string;
}
export interface DoorwayDockerBuildProps {
  buildspec: string;
  imageName: string;
  source: Artifact;
  configSource: Artifact;
  role: Role;
  dockerHubSecret: string;
}
export class DoorwayDockerBuild extends CodeBuildAction {
  constructor(stack: Stack, id: string, props: DoorwayDockerBuildProps) {
    super({
      input: props.source,
      extraInputs: [props.configSource],
      outputs: [new Artifact(`${id}-BuildOutput`)],
      actionName: `${id}-DockerBuild`,
      project: new PipelineProject(
        stack,
        id,

        {
          buildSpec: BuildSpec.fromObject(
            YAML.parse(fs.readFileSync(props.buildspec, "utf8")),
          ),
          environmentVariables: {
            ECR_REGION: { value: stack.region },
            ECR_ACCOUNT_ID: { value: stack.account },
            ECR_NAMESPACE: { value: "doorway" },
            IMAGE_NAME: { value: props.imageName },
            DOCKER_HUB_SECRET_ARN: {
              value: props.dockerHubSecret,
            },
          },
          role: props.role,
        },
      ),
    });
    const repo = new Repository(stack, `${id}-ECRRepository`, {
      repositoryName: `doorway/${props.imageName}`,
    });
    repo.grantPullPush(props.role);
  }
}
