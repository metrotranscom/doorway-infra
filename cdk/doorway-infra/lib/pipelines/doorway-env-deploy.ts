import { Stage, StageProps } from "aws-cdk-lib";
import { Artifact } from "aws-cdk-lib/aws-codepipeline";
import { Construct } from "constructs";
import { DoorwayApiServiceStack } from "../service_infra/doorway_api_service-stack";
export interface DoorwayEnvDeployProps {
  buildspec: string;
  source: Artifact;
}

export class DoorwayEnvDeployStage extends Stage {
  constructor(
    scope: Construct,
    id: string,
    props: StageProps,
    environment: string = "dev",
  ) {
    super(scope, id, props);
    const apiServiceStack = new DoorwayApiServiceStack(
      this,
      `doorway-api-service-${environment}`,
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
