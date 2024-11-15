import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import { DoorwayParametersStack } from "./doorway-parameters-stack";

export interface ParametersBuildStageProps extends cdk.StageProps {
  environment: string;
}
export class ParametersBuildStage extends cdk.Stage {
  constructor(scope: Construct, id: string, props: ParametersBuildStageProps) {
    super(scope, id, props);
    new DoorwayParametersStack(this, "doorway-parameters", {
      environment: props.environment,
    });
  }
}
