import { SecretValue, Stack } from "aws-cdk-lib";
import { Secret } from "aws-cdk-lib/aws-secretsmanager";
import { Construct } from "constructs";
import { DoorwayStackProps } from "../service_infra/doorway_api_service-stack";

export class DoorwaySecretsStack extends Stack {
  constructor(scope: Construct, id: string, props: DoorwayStackProps) {
    super(scope, id, props);
    new Secret(this, "googleId", {
      secretName: `/doorway/${props.environment}/GOOGLE_API_ID`,
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "googleEmail", {
      secretName: `/doorway/${props.environment}/GOOGLE_API_EMAIL`,
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "googleKey", {
      secretName: `/doorway/${props.environment}/GOOGLE_API_KEY`,
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });
    new Secret(this, "googleMapsKey", {
      secretName: `/doorway/${props.environment}/GOOGLE_MAPS_API_KEY`,
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });
    new Secret(this, "googleMapsMapId", {
      secretName: `/doorway/${props.environment}/GOOGLE_MAPS_MAP_ID`,
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "govDeliveryURL", {
      secretName: `/doorway/${props.environment}/GOVDELIVERY_API_URL`,
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "govDeliveryPassword", {
      secretName: `/doorway/${props.environment}/GOVDELIVERY_PASSWORD`,
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "govDeliveryUsername", {
      secretName: `/doorway/${props.environment}/GOVDELIVERY_USERNAME`,
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });
    new Secret(this, "emailApiKey", {
      secretName: `/doorway/${props.environment}/EMAIL_API_KEY`,
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "cloudinaryKey", {
      secretName: `/doorway/${props.environment}/CLOUDINARY_KEY`,
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });

    new Secret(this, "cloudinarySecret", {
      secretName: `/doorway/${props.environment}/CLOUDINARY_SECRET`,
      secretStringValue: SecretValue.unsafePlainText("changeme"),
    });
  }
}
