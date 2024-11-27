import * as cdk from "aws-cdk-lib";
import { Secret } from "aws-cdk-lib/aws-secretsmanager";
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
    const AUTH_LOCK_LOGIN_AFTER_FAILED_ATTEMPTS = new StringParameter(
      this,
      "AUTH_LOCK_LOGIN_AFTER_FAILED_ATTEMPTS",
      {
        parameterName: `/doorway/${props.environment}/internal-api/AUTH_LOCK_LOGIN_AFTER_FAILED_ATTEMPTS`,
        stringValue: "5",
      },
    );
    AUTH_LOCK_LOGIN_AFTER_FAILED_ATTEMPTS.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const CORS_ORIGINS = new StringParameter(this, "CORS_ORIGINS", {
      parameterName: `/doorway/${props.environment}/internal-api/CORS_ORIGINS`,
      stringValue: "5",
    });
    CORS_ORIGINS.applyRemovalPolicy(
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
    rdsSubnetName.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const uploadsBucketName = new StringParameter(this, "uploadsBucketName", {
      parameterName: `/doorway/${props.environment}/s3/uploadsBucketName`,
      stringValue: "changeme",
    });
    uploadsBucketName.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const apiMinTasks = new StringParameter(this, "apiMinTasks", {
      parameterName: `/doorway/${props.environment}/internal-api/minimumTasks`,
      stringValue: "1",
    });
    apiMinTasks.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const logLevel = new StringParameter(this, "logLevel", {
      parameterName: `/doorway/${props.environment}/internal-api/LOG_LEVEL`,
      stringValue: "info",
    });
    logLevel.applyRemovalPolicy(cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE);
    const tempFileClearCron = new StringParameter(this, "tempFileClearCron", {
      parameterName: `/doorway/${props.environment}/internal-api/TEMP_FILE_CLEAR_CRON_STRING`,
      stringValue: "30 * * * *",
    });
    tempFileClearCron.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const listingProcessingCron = new StringParameter(
      this,
      "listingProcessingCron",
      {
        parameterName: `/doorway/${props.environment}/internal-api/LISTING_PROCESSING_CRON_STRING`,
        stringValue: "0 * * * *",
      },
    );
    listingProcessingCron.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const lotteryProcessingCron = new StringParameter(
      this,
      "lotteryProcessingCron",
      {
        parameterName: `/doorway/${props.environment}/internal-api/LOTTERY_PROCESSING_CRON_STRING`,
        stringValue: "0 * * * *",
      },
    );
    lotteryProcessingCron.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const lotteryPublishCron = new StringParameter(this, "lotteryPublishCron", {
      parameterName: `/doorway/${props.environment}/internal-api/LOTTERY_PUBLISH_PROCESSING_CRON_STRING`,
      stringValue: "58 23 * * *",
    });
    lotteryPublishCron.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const lotteryDaysTillExpiry = new StringParameter(
      this,
      "lotteryDaysTillExpiry",
      {
        parameterName: `/doorway/${props.environment}/internal-api/LOTTERY_DAYS_TILL_EXPIRY`,
        stringValue: "45",
      },
    );
    lotteryDaysTillExpiry.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const mfaCodeLength = new StringParameter(this, "mfaCodeLength", {
      parameterName: `/doorway/${props.environment}/internal-api/MFA_CODE_LENGTH`,
      stringValue: "5",
    });
    mfaCodeLength.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const mfaCodeValid = new StringParameter(this, "mfaCodeValid", {
      parameterName: `/doorway/${props.environment}/internal-api/MFA_CODE_VALID`,
      stringValue: "600000",
    });
    mfaCodeValid.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const DUPLICATES_CLOSE_DATE = new StringParameter(
      this,
      "DUPLICATES_CLOSE_DATE",
      {
        parameterName: `/doorway/${props.environment}/internal-api/DUPLICATES_CLOSE_DATE`,
        stringValue: "2024-10-08 00:00 -08:00",
      },
    );
    DUPLICATES_CLOSE_DATE.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const DUPLICATES_PROCESSING_CRON_STRING = new StringParameter(
      this,
      "DUPLICATES_PROCESSING_CRON_STRING",
      {
        parameterName: `/doorway/${props.environment}/internal-api/DUPLICATES_PROCESSING_CRON_STRING`,
        stringValue: "5 * * * *",
      },
    );
    DUPLICATES_PROCESSING_CRON_STRING.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const GOVDELIVERY_TOPIC = new StringParameter(this, "GOVDELIVERY_TOPIC", {
      parameterName: `/doorway/${props.environment}/internal-api/GOVDELIVERY_TOPIC`,
      stringValue: "5 * * * *",
    });
    GOVDELIVERY_TOPIC.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const afsProcessingCron = new StringParameter(
      this,
      "afsProcessingCronCron",
      {
        parameterName: `/doorway/${props.environment}/internal-api/AFS_PROCESSING_CRON_STRING`,
        stringValue: "15 * * * *",
      },
    );
    afsProcessingCron.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const partnersPortalUrl = new StringParameter(this, "partnersPortalUrl", {
      parameterName: `/doorway/${props.environment}/internal-api/PARTNERS_PORTAL_URL`,
      stringValue: "https://partners.dev.housingbayarea.mtc.ca.gov",
    });
    partnersPortalUrl.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const partnersBaselUrl = new StringParameter(this, "partnersBaseUrl", {
      parameterName: `/doorway/${props.environment}/internal-api/PARTNERS_BASE_URL`,
      stringValue: "https://partners.dev.housingbayarea.mtc.ca.gov",
    });
    partnersPortalUrl.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const s3Region = new StringParameter(this, "s3Region", {
      parameterName: `/doorway/${props.environment}/internal-api/ASSET_FS_CONFIG_s3_REGION`,
      stringValue: "us-west-1",
    });
    s3Region.applyRemovalPolicy(cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE);
    const s3Url = new StringParameter(this, "s3Url", {
      parameterName: `/doorway/${props.environment}/internal-api/ASSET_FS_CONFIG_s3_URL_FORMAT`,
      stringValue: "public",
    });
    s3Url.applyRemovalPolicy(cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE);
    const throttleTTL = new StringParameter(this, "throttleTTL", {
      parameterName: `/doorway/${props.environment}/internal-api/THROTTLE_TTL`,
      stringValue: "180000",
    });
    throttleTTL.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const throttleLimit = new StringParameter(this, "throttleLimit", {
      parameterName: `/doorway/${props.environment}/internal-api/THROTTLE_LIMIT`,
      stringValue: "180000",
    });
    throttleLimit.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const uploadMaxSize = new StringParameter(this, "uploadMaxSize", {
      parameterName: `/doorway/${props.environment}/internal-api/ASSET_UPLOAD_MAX_SIZE`,
      stringValue: "5",
    });
    uploadMaxSize.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const authLockCooldown = new StringParameter(this, "authLockCooldown", {
      parameterName: `/doorway/${props.environment}/internal-api/AUTH_LOCK_LOGIN_COOLDOWN`,
      stringValue: "5",
    });
    authLockCooldown.applyRemovalPolicy(
      cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
    );
    const appSecret = new Secret(this, "appSecret", {
      secretName: `app-secret-${props.environment}`,
      secretStringValue: cdk.SecretValue.unsafePlainText(
        "<dummy-value-that-is-at-least-16-character-long>",
      ),
    });
    appSecret.applyRemovalPolicy(cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE);
    // These secrets are shared accross environments so they should only be in one stack
    if (props.environment === "prod") {
      const googleId = new Secret(this, "googleId", {
        secretName: "GOOGLE_API_ID",
        secretStringValue: cdk.SecretValue.unsafePlainText("changeme"),
      });
      googleId.applyRemovalPolicy(cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE);
      const googleEmail = new Secret(this, "googleEmail", {
        secretName: "GOOGLE_API_EMAIL",
        secretStringValue: cdk.SecretValue.unsafePlainText("changeme"),
      });
      googleEmail.applyRemovalPolicy(
        cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
      );
      const googleKey = new Secret(this, "googleKey", {
        secretName: "GOOGLE_API_KEY",
        secretStringValue: cdk.SecretValue.unsafePlainText("changeme"),
      });
      googleKey.applyRemovalPolicy(
        cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
      );
      const govDeliveryURL = new Secret(this, "govDeliveryURL", {
        secretName: "GOVDELIVERY_API_URL",
        secretStringValue: cdk.SecretValue.unsafePlainText("changeme"),
      });
      govDeliveryURL.applyRemovalPolicy(
        cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
      );
      const govDeliveryPassword = new Secret(this, "govDeliveryPassword", {
        secretName: "GOVDELIVERY_PASSWORD",
        secretStringValue: cdk.SecretValue.unsafePlainText("changeme"),
      });
      govDeliveryPassword.applyRemovalPolicy(
        cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
      );
      const govDeliveryUsername = new Secret(this, "govDeliveryUsername", {
        secretName: "GOVDELIVERY_USERNAME",
        secretStringValue: cdk.SecretValue.unsafePlainText("changeme"),
      });
      govDeliveryUsername.applyRemovalPolicy(
        cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
      );
      const emailApiKey = new Secret(this, "emailApiKey", {
        secretName: "EMAIL_API_KEY",
        secretStringValue: cdk.SecretValue.unsafePlainText("changeme"),
      });
      emailApiKey.applyRemovalPolicy(
        cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
      );
      const cloudinaryKey = new Secret(this, "cloudinaryKey", {
        secretName: "CLOUDINARY_KEY",
        secretStringValue: cdk.SecretValue.unsafePlainText("changeme"),
      });
      cloudinaryKey.applyRemovalPolicy(
        cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
      );
      const cloudinarySecret = new Secret(this, "cloudinarySecret", {
        secretName: "CLOUDINARY_SECRET",
        secretStringValue: cdk.SecretValue.unsafePlainText("changeme"),
      });
      cloudinarySecret.applyRemovalPolicy(
        cdk.RemovalPolicy.RETAIN_ON_UPDATE_OR_DELETE,
      );
    }
  }
}
