import { Stack, StackProps } from "aws-cdk-lib";
import { ConfigurationSet, EmailIdentity, Identity } from "aws-cdk-lib/aws-ses";
import { StringParameter } from "aws-cdk-lib/aws-ssm";
import { Construct } from "constructs";

export class DoorwayGlobalResourcesStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    // Set up the SES Configuration (A fake one for sandbox use)
    const sesConfigSet = new ConfigurationSet(this, "DoorwaySesConfigSet", {
      configurationSetName: "DoorwaySesConfigSet",
      sendingEnabled: true,
    });

    new EmailIdentity(this, "DoorwaySesIdentity", {
      identity: Identity.domain("housingbayarea2.org"),
      configurationSet: sesConfigSet,
      dkimSigning: true,
      feedbackForwarding: true,
    });
    // Store the ID of our public Route53 DNS Zone
    new StringParameter(this, "publicHostedZone", {
      parameterName: "/doorway/public-hosted-zone",
      stringValue: "Z01682742VM0KIXZ4Y3W5",
    });
    // Store the ARN of our private cert authority (This might be unnecessary now)
    new StringParameter(this, "privateCertAuthority", {
      parameterName: `/doorway/privateCertAuthority`,
      stringValue:
        "arn:aws:acm-pca:us-west-2:364076391763:certificate-authority/38e4d2b0-d431-46ff-944d-dab8ce318d2e",
    });
  }
}
