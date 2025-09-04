import { CfnOutput, Stack } from "aws-cdk-lib";
import { Bucket } from "aws-cdk-lib/aws-s3";
import { Construct } from "constructs";

export class DoorwayS3Stack extends Stack {
  constructor(scope: Construct, id: string, props: { environment: string }) {
    super(scope, id);

    const secureUploadsBucket = new Bucket(this, "secureUploadsBucket", {
      bucketName: `doorway-secure-uploads-${props.environment}`,
      blockPublicAccess: {
        blockPublicAcls: true,
        blockPublicPolicy: true,
        ignorePublicAcls: true,
        restrictPublicBuckets: true,
      },
      enforceSSL: true,
    });

    // Output the bucket name
    new CfnOutput(this, "SecureBucketName", {
      exportName: `doorway-secure-uploads-${props.environment}`,
      value: secureUploadsBucket.bucketArn,
      description: `Doorway Secure Uploads Bucket ARN for the ${props.environment} environment`,
    });
    const publicUploadsBucket = new Bucket(this, "publicUploadsBucket", {
      bucketName: `doorway-public-uploads-${props.environment}`,
      blockPublicAccess: {
        blockPublicAcls: false,
        blockPublicPolicy: false,
        ignorePublicAcls: false,
        restrictPublicBuckets: false,
      },
      enforceSSL: true,
    });
    publicUploadsBucket.grantPublicAccess();

    // Output the bucket name
    new CfnOutput(this, "PublicBucketName", {
      exportName: `doorway-public-uploads-${props.environment}`,
      value: publicUploadsBucket.bucketArn,
      description: `Doorway Public Uploads Bucket ARN for the ${props.environment} environment`,
    });
  }
}
