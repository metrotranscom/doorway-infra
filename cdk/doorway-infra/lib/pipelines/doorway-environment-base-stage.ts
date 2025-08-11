import { Stage, StageProps } from "aws-cdk-lib";
import { Construct } from "constructs";
import { DoorwayDatabaseServerStack } from "../doorway-database-server-stack";
import { DoorwayEcsClusterStack } from "../doorway-ecs-cluster";
import { DoorwayNetworkStack } from "../doorway-network-stack";
import { DoorwayParametersStack } from "../doorway-parameters-stack";

export class DoorwayEnvironmentBaseStage extends Stage {
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
