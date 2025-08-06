import { SecretValue, Stack, StackProps } from "aws-cdk-lib";
import { Secret } from "aws-cdk-lib/aws-secretsmanager";
import { ConfigurationSet, EmailIdentity, Identity } from "aws-cdk-lib/aws-ses";
import { Construct } from "constructs";
import { DoorwayBuildPipelineStack } from "./pipelines/doorway-build-pipeline-stack";

export class DoorwayGlobalResourcesStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);
    const sesConfigSet = new ConfigurationSet(this, "DoorwaySesConfigSet", {
      configurationSetName: "DoorwaySesConfigSet",
      sendingEnabled: true,
    });
    new DoorwayBuildPipelineStack(this, "DoorwayBuildPipelineStack", {
      dockerHubSecret: "DOCKER_HUB_SECRET",
      githubSecret: "GITHUB_SECRET",
    });

    new EmailIdentity(this, "DoorwaySesIdentity", {
      identity: Identity.domain("housingbayarea2.org"),
      configurationSet: sesConfigSet,
      dkimSigning: true,
      feedbackForwarding: true,
    });
    new Secret(this, "googleId", {
      secretName: "GOOGLE_API_ID",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "googleEmail", {
      secretName: "GOOGLE_API_EMAIL",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "googleKey", {
      secretName: "GOOGLE_API_KEY",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "govDeliveryURL", {
      secretName: "GOVDELIVERY_API_URL",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "govDeliveryPassword", {
      secretName: "GOVDELIVERY_PASSWORD",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "govDeliveryUsername", {
      secretName: "GOVDELIVERY_USERNAME",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });
    new Secret(this, "emailApiKey", {
      secretName: "EMAIL_API_KEY",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "cloudinaryKey", {
      secretName: "CLOUDINARY_KEY",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "cloudinarySecret", {
      secretName: "CLOUDINARY_SECRET",
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });
  }
}
