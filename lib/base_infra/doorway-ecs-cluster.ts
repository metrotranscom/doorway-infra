import { CfnOutput, Fn, Stack } from "aws-cdk-lib";
import { Vpc } from "aws-cdk-lib/aws-ec2";
import { Cluster, ContainerInsights } from "aws-cdk-lib/aws-ecs";
import { Construct } from "constructs";

import { DoorwayStackProps } from "./doorway-stack-props";

/** @class
 * This is the CDK Stack that creates an ECS Cluster where services can run
 */
export class DoorwayEcsClusterStack extends Stack {
  /**
   * @constructor
   * @param Construct scope - the CDK Execution Context this is running in
   * @param string id - unique name for the stack
   * @param DoorwayStackProps props - in addition to the properties inherited by the CDK StackProps class, adds a string property of "environment" which is the name of the Doorway environment.
   */
  constructor(scope: Construct, id: string, props: DoorwayStackProps) {
    super(scope, id, props);

    // Get network information
    const vpcId = Fn.importValue(`mtc-vpc-id-${props.environment}`);
    const vpc = Vpc.fromVpcAttributes(this, "vpc", {
      vpcId: vpcId,
      availabilityZones: ["us-west-2a", "us-west-2b"],
    });

    // Create the cluster
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
    // Stack export in for the cluster name
    new CfnOutput(this, "doorwayEcsClusterName", {
      value: cluster.clusterName,
      exportName: `doorway-ecs-cluster-${props.environment}`,
    });
  }
}
