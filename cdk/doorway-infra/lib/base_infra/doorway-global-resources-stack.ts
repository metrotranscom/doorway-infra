import { SecretValue, Stack, StackProps } from "aws-cdk-lib";
import { Secret } from "aws-cdk-lib/aws-secretsmanager";
import { ConfigurationSet, EmailIdentity, Identity } from "aws-cdk-lib/aws-ses";
import { StringParameter } from "aws-cdk-lib/aws-ssm";
import { Construct } from "constructs";
import { DoorwayBuildPipelineStack } from "../pipelines/doorway-build-pipeline-stack";

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
    new Secret(this, "googleId", {
      secretName: "/doorway/GOOGLE_API_ID",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "googleEmail", {
      secretName: "/doorway/GOOGLE_API_EMAIL",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "googleKey", {
      secretName: "/doorway/GOOGLE_API_KEY",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });
    new Secret(this, "googleMapsKey", {
      secretName: "/doorway/GOOGLE_MAPS_API_KEY",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "govDeliveryURL", {
      secretName: "/doorway/GOVDELIVERY_API_URL",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "govDeliveryPassword", {
      secretName: "/doorway/GOVDELIVERY_PASSWORD",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "govDeliveryUsername", {
      secretName: "/doorway/GOVDELIVERY_USERNAME",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });
    new Secret(this, "emailApiKey", {
      secretName: "/doorway/EMAIL_API_KEY",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "cloudinaryKey", {
      secretName: "/doorway/CLOUDINARY_KEY",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "cloudinarySecret", {
      secretName: "/doorway/CLOUDINARY_SECRET",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });
    new StringParameter(this, "publicHostedZone", {
      parameterName: "/doorway/public-hosted-zone",
      stringValue: "Z01682742VM0KIXZ4Y3W5",
    });
    new StringParameter(this, "privateHostedZone", {
      parameterName: "/doorway/private-hosted-zone",
      stringValue: "Z084253138VJG63K273SM",
    });
    new DoorwayBuildPipelineStack(this, "DoorwayBuildPipelineStack", {
      dockerHubSecret: "mtc/dockerHub",
      githubSecret: "mtc/githubSecret",
    });
  }
}
