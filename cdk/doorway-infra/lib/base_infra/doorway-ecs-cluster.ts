import { CfnOutput, Fn, Stack } from "aws-cdk-lib";
import { Vpc } from "aws-cdk-lib/aws-ec2";

import { Cluster, ContainerInsights } from "aws-cdk-lib/aws-ecs";
import { Construct } from "constructs";
import { DoorwayStackProps } from "../service_infra/doorway_api_service-stack";

export class DoorwayEcsClusterStack extends Stack {
  constructor(scope: Construct, id: string, props: DoorwayStackProps) {
    super(scope, id, props);
    const vpcId = Fn.importValue(`mtc-vpc-id-${props.environment}`);

    const vpc = Vpc.fromVpcAttributes(this, "vpc", {
      vpcId: vpcId,
      availabilityZones: ["us-west-2a", "us-west-2b"],
    });
    const cluster = new Cluster(
      this,
      `doorway-ecs-cluster-${props.environment}`,
      {
        clusterName: `doorway-ecs-cluster-${props.environment}`,
        vpc: vpc,
        containerInsightsV2: ContainerInsights.ENHANCED,
        enableFargateCapacityProviders: true,
      },
    );
    new CfnOutput(this, "doorwayEcsClusterName", {
      value: cluster.clusterName,
      exportName: `doorway-ecs-cluster-${props.environment}`,
    });
  }
}
