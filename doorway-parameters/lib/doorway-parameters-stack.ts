import * as cdk from 'aws-cdk-lib';
import { StringListParameter, StringParameter } from 'aws-cdk-lib/aws-ssm';
import { Construct } from 'constructs';
// import * as sqs from 'aws-cdk-lib/aws-sqs';
export class DoorwayParametersStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);
    const environment = process.env.ENVIRONMENT
    const vpcIdParametger = new StringParameter(this, 'vpcId', {
      parameterName: `/doorway/${environment}/vpc/id`,
      stringValue: 'vpc-0e0e0e0e0e0e0e0e0',
    });
    const publicSubnetsParm = new StringListParameter(this, 'publicSubnets', {
      parameterName: `/doorway/${environment}/vpc/publicSubnets`,
      stringListValue: ['subnet-0e0e0e0e0e0e0e0e0', 'subnet-0e0e0e0e0e0e0e0e1'],
    })
    const appSubnetsParm = new StringListParameter(this, 'appSubnets', {
      parameterName: `/doorway/${environment}/vpc/appSubnets`,
      stringListValue: ['subnet-0e0e0e0e0e0e0e0e0', 'subnet-0e0e0e0e0e0e0e0e1'],
    })
    const dbSubnetsParm = new StringListParameter(this, 'dbSubnets', {
      parameterName: `/doorway/${environment}/vpc/dbSubnets`,
      stringListValue: ['subnet-0e0e0e0e0e0e0e0e0', 'subnet-0e0e0e0e0e0e0e0e1'],
    })
  }
}
