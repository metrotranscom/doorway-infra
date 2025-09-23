import { Stage, StageProps } from "aws-cdk-lib";
import { Construct } from "constructs";
import { DoorwayDatabaseServerStack } from "../base_infra/doorway-database-server-stack";
import { DoorwayEcsClusterStack } from "../base_infra/doorway-ecs-cluster";
import { DoorwayNetworkStack } from "../base_infra/doorway-network-stack";

export class DoorwayEnvironmentBaseStage extends Stage {
  constructor(
    scope: Construct,
    id: string,
    props?: StageProps,
    environment: string = "dev",
  ) {
    super(scope, id, props);
    const networkstack = new DoorwayNetworkStack(
      this,
      `DoorwayNetworkStack-${environment}`,
      {
        stackName: `DoorwayNetworkStack-${environment}`,
        environment: environment,
        env: {
          account: process.env.CDK_DEFAULT_ACCOUNT || "no-account",
          region: process.env.CDK_DEFAULT_REGION || "no-region",
        },
      },
    );

    const dbstack = new DoorwayDatabaseServerStack(
      this,
      `DoorwayDatabaseServerStack-${environment}`,
      {
        stackName: `DoorwayDatabaseServerStack-${environment}`,
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
      `DoorwayEcsClusterStack-${environment}`,
      {
        stackName: `DoorwayEcsClusterStack-${environment}`,
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
