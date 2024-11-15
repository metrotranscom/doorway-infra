import { Stack, StackProps } from "aws-cdk-lib";
import { PolicyStatement, Role, ServicePrincipal } from "aws-cdk-lib/aws-iam";
import { Secret } from "aws-cdk-lib/aws-secretsmanager";
import {
  CodeBuildStep,
  CodePipeline,
  CodePipelineSource,
} from "aws-cdk-lib/pipelines";
import { Construct } from "constructs";
import { ParametersBuildStage } from "./parameters-stage";
export class DoorwayServicesInfraPipelineStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id);
    const githubSecret = Secret.fromSecretNameV2(
      this,
      "githubSecret",
      "/doorway/githubSecret",
    ).secretValue;
    const pipelineRole = new Role(this, "doorway-services-pipeline-role", {
      assumedBy: new ServicePrincipal("codepipeline.amazonaws.com"),
    });
    pipelineRole.addToPolicy(
      new PolicyStatement({
        actions: ["cloudformation:*", "ec2:*", "ssm:*"],
        resources: ["*"],
      }),
    );
    const pipeline = new CodePipeline(this, "Doorway-Service-Infra-Pipeline", {
      pipelineName: "doorway-services-infra",
      selfMutation: true,
      role: pipelineRole,
      synth: new CodeBuildStep("Synth", {
        input: CodePipelineSource.gitHub(
          "metrotranscom/doorway-infra",
          "cdk-main",
          {
            authentication: githubSecret,
          },
        ),
        commands: [
          "cd doorway-services",
          "yarn install",
          "yarn build",
          "yarn cdk synth",
        ],
        primaryOutputDirectory: "./cdk.out",
        rolePolicyStatements: [
          new PolicyStatement({
            actions: ["cloudformation:*", "ec2:*", "ssm:*"],
            resources: ["*"],
          }),
        ],
      }),
    });
    pipeline.addStage(
      new ParametersBuildStage(this, "dev-parameters", {
        environment: "dev",
      }),
    );
  }
}
