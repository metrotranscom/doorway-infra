import { Stage, StageProps } from "aws-cdk-lib";
import { Construct } from "constructs";
import { DoorwayDatabaseServerStack } from "../base_infra/doorway-database-server-stack";
import { DoorwayEcsClusterStack } from "../base_infra/doorway-ecs-cluster";
import { DoorwayNetworkStack } from "../base_infra/doorway-network-stack";
import { DoorwayS3Stack } from "../base_infra/doorway-s3-stack";
import { DoorwayParametersStack } from "../service_infra/doorway-parameters-stack";

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
    const s3BucketStack = new DoorwayS3Stack(this, "DoorwayS3BucketStack", {
      environment: environment,
    });
  }
}
