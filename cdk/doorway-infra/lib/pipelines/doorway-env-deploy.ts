import { Stack } from "aws-cdk-lib";
import { Artifact } from "aws-cdk-lib/aws-codepipeline";
import {
  PolicyDocument,
  PolicyStatement,
  Role,
  ServicePrincipal,
} from "aws-cdk-lib/aws-iam";
export interface DoorwayEnvDeployProps {
  buildspec: string;
  source: Artifact;
}

export class DoorwayEnvDeploy {
  constructor(stack: Stack, id: string, props: DoorwayEnvDeployProps) {
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
              actions: ["secretsmanager:GetSecretValue"],
              resources: [
                `arn:aws:secretsmanager:${stack.region}:${stack.account}:secret:mtc/dockerHub*`,
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
  }
}
