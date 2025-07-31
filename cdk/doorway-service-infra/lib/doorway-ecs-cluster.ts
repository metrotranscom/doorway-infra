import { Fn, Stack } from "aws-cdk-lib";
import { Vpc } from "aws-cdk-lib/aws-ec2";

import { Cluster, ContainerInsights } from "aws-cdk-lib/aws-ecs";
import { Construct } from "constructs";
import { DoorwayStackProps } from "./doorway_api_service-stack";

export class DoorwayEcsClusterStack extends Stack {
  constructor(scope: Construct, id: string, props: DoorwayStackProps) {
    super(scope, id, props);
    const vpcId = Fn.importValue(`mtc-vpc-id-${props.environment}`);
    const appSGId = Fn.importValue(`mtc-app-sg-${props.environment}`);

    const vpc = Vpc.fromVpcAttributes(this, "vpc", {
      vpcId: vpcId,
      availabilityZones: ["us-west-2a", "us-west-2b"],
    });
    new Cluster(this, `doorway-ecs-cluster-${props.environment}`, {
      clusterName: `doorway-ecs-cluster-${props.environment}`,
      vpc: vpc,
      containerInsightsV2: ContainerInsights.ENHANCED,
      enableFargateCapacityProviders: true,
    });
  }
}
