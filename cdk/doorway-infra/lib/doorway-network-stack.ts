import { CfnOutput, Stack } from "aws-cdk-lib";
import {
  IpAddresses,
  Port,
  SecurityGroup,
  SubnetType,
  Vpc,
} from "aws-cdk-lib/aws-ec2";
import { Construct } from "constructs";
import { DoorwayStackProps } from "./doorway_api_service-stack";

export class DoorwayNetworkStack extends Stack {
  constructor(scope: Construct, id: string, props: DoorwayStackProps) {
    super(scope, id, props);
    const vpc: Vpc = new Vpc(this, "doorway-core-vpc", {
      vpcName: `doorway-${props.environment}`,
      ipAddresses: IpAddresses.cidr("10.3.0.0/16"),
      maxAzs: 2,
      enableDnsHostnames: true,
      enableDnsSupport: true,
      subnetConfiguration: [
        {
          name: `doorway-public-${props.environment}`,
          cidrMask: 24,
          subnetType: SubnetType.PUBLIC,
        },
        {
          name: `doorway-app-${props.environment}`,
          cidrMask: 22,
          subnetType: SubnetType.PRIVATE_WITH_EGRESS,
        },
        {
          name: `doorway-db-${props.environment}`,
          cidrMask: 24,
          subnetType: SubnetType.PRIVATE_WITH_EGRESS,
        },
      ],
    });

    const appSG = new SecurityGroup(
      this,
      `doorway-app-sg-${props.environment}`,
      {
        vpc: vpc,
        securityGroupName: `doorway-app-sg-${props.environment}`,
        description: `App security group for the doorway ${props.environment} environment`,
      },
    );
    appSG.addEgressRule(appSG, Port.allTcp(), "Allow all outbound traffic");
    new CfnOutput(this, "doorway-app-sg", {
      exportName: `doorway-app-sg-${props.environment}`,
      description: `The app security group for the doorway ${props.environment} environment`,
      value: appSG.securityGroupId,
    });
    new CfnOutput(this, "doorway-default-sg", {
      exportName: `doorway-default-sg-${props.environment}`,
      description: `The default security group for the doorway ${props.environment} environment`,
      value: vpc.vpcDefaultSecurityGroup,
    });
    new CfnOutput(this, "doorway-vpc-id", {
      exportName: `doorway-vpc-id-${props.environment}`,
      description: `The VPC for the doorway for the ${props.environment} environment`,
      value: vpc.vpcId,
    });
    new CfnOutput(this, `doorway-db-subnet-1-${props.environment}`, {
      value: vpc.selectSubnets({
        subnetGroupName: `doorway-db-${props.environment}`,
      }).subnets[0].subnetId,
      exportName: `doorway-db-subnet-1-${props.environment}`,
    });
    new CfnOutput(this, `doorway-db-subnet-2-${props.environment}`, {
      value: vpc.selectSubnets({
        subnetGroupName: `doorway-db-${props.environment}`,
      }).subnets[1].subnetId,
      exportName: `doorway-db-subnet-2-${props.environment}`,
    });
    new CfnOutput(this, `doorway-azs-${props.environment}`, {
      value: vpc.availabilityZones.join(", "),
      exportName: `doorway-azs-${props.environment}`,
    });
    new CfnOutput(this, `doorway-public-subnet-1-${props.environment}`, {
      value: vpc.selectSubnets({
        subnetGroupName: `doorway-public-${props.environment}`,
      }).subnets[0].subnetId,
      exportName: `doorway-public-subnet-1-${props.environment}`,
    });
    new CfnOutput(this, `doorway-public-subnet-2-${props.environment}`, {
      value: vpc.selectSubnets({
        subnetGroupName: `doorway-public-${props.environment}`,
      }).subnets[1].subnetId,
      exportName: `doorway-public-subnet-2-${props.environment}`,
    });
    new CfnOutput(this, `doorway-app-subnet-1-${props.environment}`, {
      value: vpc.selectSubnets({
        subnetGroupName: `doorway-app-${props.environment}`,
      }).subnets[0].subnetId,
      exportName: `doorway-app-subnet-1-${props.environment}`,
    });
    new CfnOutput(this, `doorway-app-subnet-2-${props.environment}`, {
      value: vpc.selectSubnets({
        subnetGroupName: `doorway-app-${props.environment}`,
      }).subnets[1].subnetId,
      exportName: `doorway-app-subnet-2-${props.environment}`,
    });
  }
}
