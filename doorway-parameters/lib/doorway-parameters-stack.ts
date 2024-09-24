import * as cdk from "aws-cdk-lib";
import { StringListParameter, StringParameter } from "aws-cdk-lib/aws-ssm";
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
    const vpcIdParameter = new StringParameter(this, "vpcId", {
      parameterName: `/doorway/${props.environment}/vpc/id`,
      stringValue: "vpc-0e0e0e0e0e0e0e0e0",
    });
    vpcIdParameter.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const publicSubnetsParm = new StringListParameter(this, "publicSubnets", {
      parameterName: `/doorway/${props.environment}/vpc/publicSubnets`,
      stringListValue: ["subnet-0e0e0e0e0e0e0e0e0", "subnet-0e0e0e0e0e0e0e0e1"],
    });
    publicSubnetsParm.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const appSubnetsParm = new StringListParameter(this, "appSubnets", {
      parameterName: `/doorway/${props.environment}/vpc/appSubnets`,
      stringListValue: ["subnet-0e0e0e0e0e0e0e0e0", "subnet-0e0e0e0e0e0e0e0e1"],
    });
    appSubnetsParm.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const dbSubnetsParm = new StringListParameter(this, "dbSubnets", {
      parameterName: `/doorway/${props.environment}/vpc/dbSubnets`,
      stringListValue: ["subnet-0e0e0e0e0e0e0e0e0", "subnet-0e0e0e0e0e0e0e0e1"],
    });
    dbSubnetsParm.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const dbSecretParm = new StringParameter(this, "dbSecret", {
      parameterName: `/doorway/${props.environment}/db/secret`,
      stringValue: "dbSecret",
    });
    dbSecretParm.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const ecsClusterArn = new StringParameter(this, "ecsClusterArm", {
      parameterName: `/doorway/${props.environment}/ecs/clusterArn`,
      stringValue: "changeme",
    });
    ecsClusterArn.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const rdsInstanceName = new StringParameter(this, "rdsInstanceName", {
      parameterName: `/doorway/${props.environment}/rds/instanceName`,
      stringValue: "changeme",
    });
    rdsInstanceName.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const rdsSubnetName = new StringParameter(this, "rdsSubnetGroupName", {
      parameterName: `/doorway/${props.environment}/rds/subnetGroupName`,
      stringValue: "changeme",
    });
    rdsInstanceName.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const uploadsBucketName = new StringParameter(this, "uploadsBucketName", {
      parameterName: `/doorway/${props.environment}/s3/uploadsBucketName`,
      stringValue: "changeme",
    });
    uploadsBucketName.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
  }
}
