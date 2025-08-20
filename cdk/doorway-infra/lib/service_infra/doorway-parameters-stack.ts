import * as cdk from "aws-cdk-lib";
import { StringParameter } from "aws-cdk-lib/aws-ssm";
import { Construct } from "constructs";
// import * as sqs from 'aws-cdk-lib/aws-sqs';
export interface DoorwayParametersStackProps extends cdk.StackProps {
  environment: string;
}
export class DoorwayParametersStack extends cdk.Stack {
  constructor(
    scope: Construct,
    id: string,
    props: DoorwayParametersStackProps = { environment: "dev" },
  ) {
    super(scope, id, props);
    new StringParameter(this, "privateCertAuthority", {
      parameterName: `/doorway/privateCertAuthority`,
      stringValue:
        "arn:aws:acm-pca:us-west-2:364076391763:certificate-authority/38e4d2b0-d431-46ff-944d-dab8ce318d2e",
    });
  }
}
