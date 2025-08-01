import { Stack, StackProps } from "aws-cdk-lib";

import { ConfigurationSet, EmailIdentity, Identity } from "aws-cdk-lib/aws-ses";
import { Construct } from "constructs";

export class DoorwayGlobalResourcesStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);
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
  }
}
