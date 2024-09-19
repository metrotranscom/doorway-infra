import * as cdk from 'aws-cdk-lib';
import { ISubnet, Subnet, Vpc } from 'aws-cdk-lib/aws-ec2';
import { NetworkLoadBalancer } from 'aws-cdk-lib/aws-elasticloadbalancingv2';
import { StringListParameter, StringParameter } from 'aws-cdk-lib/aws-ssm';
import { Construct } from 'constructs';
// import * as sqs from 'aws-cdk-lib/aws-sqs';
export class DoorwayNetworkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);
    const environment = process.env.ENVIRONMENT
    const vpcId = StringParameter.fromStringParameterAttributes(this, 'vpcId', {
      parameterName: `/doorway/${environment}/vpc/id`,
    }).stringValue
    const appSubnets = StringListParameter.fromListParameterAttributes(this, 'appSubnets', {
      parameterName: `/doorway/${environment}/vpc/appSubnets`,
    }).stringListValue
    const vpc = Vpc.fromVpcAttributes(this, 'vpc', {
      vpcId: vpcId,
      availabilityZones: ['us-west-1a','us-west-1c']
    })
    const subnets: ISubnet[] = appSubnets.map((subnetId) => {
      return Subnet.fromSubnetAttributes(this, 'subnet', {
        subnetId: subnetId,
      })
    })
    const nlb  = new NetworkLoadBalancer(this, 'apiNlb', {
      vpc: vpc,
      internetFacing: false,
      vpcSubnets: {
        subnets:subnets
         }
    })
  }
}
