import * as cdk from "aws-cdk-lib";
import { Secret } from "aws-cdk-lib/aws-secretsmanager";
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
    new StringParameter(this, "AUTH_LOCK_LOGIN_AFTER_FAILED_ATTEMPTS", {
      parameterName: `/doorway/${props.environment}/internal-api/AUTH_LOCK_LOGIN_AFTER_FAILED_ATTEMPTS`,
      stringValue: "5",
    });
    new StringParameter(this, "CORS_ORIGINS", {
      parameterName: `/doorway/${props.environment}/internal-api/CORS_ORIGINS`,
      stringValue: "5",
    });
    new StringParameter(this, "logLevel", {
      parameterName: `/doorway/${props.environment}/internal-api/LOG_LEVEL`,
      stringValue: "info",
    });
    new StringParameter(this, "tempFileClearCron", {
      parameterName: `/doorway/${props.environment}/internal-api/TEMP_FILE_CLEAR_CRON_STRING`,
      stringValue: "30 * * * *",
    });

    new StringParameter(this, "listingProcessingCron", {
      parameterName: `/doorway/${props.environment}/internal-api/LISTING_PROCESSING_CRON_STRING`,
      stringValue: "0 * * * *",
    });

    new StringParameter(this, "lotteryProcessingCron", {
      parameterName: `/doorway/${props.environment}/internal-api/LOTTERY_PROCESSING_CRON_STRING`,
      stringValue: "0 * * * *",
    });

    new StringParameter(this, "lotteryPublishCron", {
      parameterName: `/doorway/${props.environment}/internal-api/LOTTERY_PUBLISH_PROCESSING_CRON_STRING`,
      stringValue: "58 23 * * *",
    });

    new StringParameter(this, "lotteryDaysTillExpiry", {
      parameterName: `/doorway/${props.environment}/internal-api/LOTTERY_DAYS_TILL_EXPIRY`,
      stringValue: "45",
    });

    new StringParameter(this, "mfaCodeLength", {
      parameterName: `/doorway/${props.environment}/internal-api/MFA_CODE_LENGTH`,
      stringValue: "5",
    });
    new StringParameter(this, "mfaCodeValid", {
      parameterName: `/doorway/${props.environment}/internal-api/MFA_CODE_VALID`,
      stringValue: "600000",
    });

    new StringParameter(this, "DUPLICATES_CLOSE_DATE", {
      parameterName: `/doorway/${props.environment}/internal-api/DUPLICATES_CLOSE_DATE`,
      stringValue: "2024-10-08 00:00 -08:00",
    });

    new StringParameter(this, "DUPLICATES_PROCESSING_CRON_STRING", {
      parameterName: `/doorway/${props.environment}/internal-api/DUPLICATES_PROCESSING_CRON_STRING`,
      stringValue: "5 * * * *",
    });

    const GOVDELIVERY_TOPIC = new StringParameter(this, "GOVDELIVERY_TOPIC", {
      parameterName: `/doorway/${props.environment}/internal-api/GOVDELIVERY_TOPIC`,
      stringValue: "5 * * * *",
    });

    new StringParameter(this, "afsProcessingCronCron", {
      parameterName: `/doorway/${props.environment}/internal-api/AFS_PROCESSING_CRON_STRING`,
      stringValue: "15 * * * *",
    });

    new StringParameter(this, "partnersPortalUrl", {
      parameterName: `/doorway/${props.environment}/internal-api/PARTNERS_PORTAL_URL`,
      stringValue: "https://partners.dev.housingbayarea.mtc.ca.gov",
    });

    new StringParameter(this, "partnersBaseUrl", {
      parameterName: `/doorway/${props.environment}/internal-api/PARTNERS_BASE_URL`,
      stringValue: "https://partners.dev.housingbayarea.mtc.ca.gov",
    });

    new StringParameter(this, "throttleTTL", {
      parameterName: `/doorway/${props.environment}/internal-api/THROTTLE_TTL`,
      stringValue: "180000",
    });

    new StringParameter(this, "throttleLimit", {
      parameterName: `/doorway/${props.environment}/internal-api/THROTTLE_LIMIT`,
      stringValue: "180000",
    });

    new StringParameter(this, "uploadMaxSize", {
      parameterName: `/doorway/${props.environment}/internal-api/ASSET_UPLOAD_MAX_SIZE`,
      stringValue: "5",
    });

    new StringParameter(this, "authLockCooldown", {
      parameterName: `/doorway/${props.environment}/internal-api/AUTH_LOCK_LOGIN_COOLDOWN`,
      stringValue: "5",
    });

    new StringParameter(this, "httpsOff", {
      parameterName: `/doorway/${props.environment}/internal-api/HTTPS_OFF`,
      stringValue: "false",
    });

    new StringParameter(this, "sameSite", {
      parameterName: `/doorway/${props.environment}/internal-api/SAME_SITE`,
      stringValue: "true",
    });

    new StringParameter(this, "cookieDomain", {
      parameterName: `/doorway/${props.environment}/internal-api/COOKIE_DOMAIN`,
      stringValue: `.${props.environment}.housingbayarea.mtc.ca.gov`,
    });

    new StringParameter(this, "useSecureDownloadPathway", {
      parameterName: `/doorway/${props.environment}/partners-portal/USE_SECURE_DOWNLOAD_PATHWAY`,
      stringValue: `TRUE`,
    });
    new StringParameter(this, "cacheRevalidate", {
      parameterName: `/doorway/${props.environment}/public-portal/CACHE_REVALIDATE`,
      stringValue: "60",
    });
    new StringParameter(this, "bloomApiBase", {
      parameterName: `/doorway/${props.environment}/public-portal/BLOOM_API_BASE`,
      stringValue: "https://proxy.housingbayarea.org",
    });
    new StringParameter(this, "gtmKey", {
      parameterName: `/doorway/${props.environment}/public-portal/GTM_KEY`,
      stringValue: "G-MNLZ682PHQ",
    });
    new StringParameter(this, "idleTimeout", {
      parameterName: `/doorway/${props.environment}/public-portal/IDLE_TIMEOUT`,
      stringValue: "5",
    });
    new StringParameter(this, "jurisdictionName", {
      parameterName: `/doorway/${props.environment}/public-portal/JURISDICTION_NAME`,
      stringValue: "Bay Area",
    });
    new StringParameter(this, "languages", {
      parameterName: `/doorway/${props.environment}/public-portal/LANGUAGES`,
      stringValue: "en,es,zh,vi,tl",
    });
    new StringParameter(this, "listingsQuery", {
      parameterName: `/doorway/${props.environment}/public-portal/LISTINGS_QUERY`,
      stringValue: "/listings",
    });
    new StringParameter(this, "notificationsSignupURL", {
      parameterName: `/doorway/${props.environment}/public-portal/NOTFICATIONS_SIGN_UP_URL`,
      stringValue: "https://public.govdelivery.com/accounts/CAMTC/signup/36832",
    });
    new StringParameter(this, "showAllMapPins", {
      parameterName: `/doorway/${props.environment}/public-portal/SHOW_ALL_MAP_PINS`,
      stringValue: "TRUE",
    });
    new StringParameter(this, "showProfessionalPartners", {
      parameterName: `/doorway/${props.environment}/public-portal/SHOW_PROFESSIONAL_PARTNERS`,
      stringValue: "TRUE",
    });

    new Secret(this, "appSecret", {
      secretName: `app-secret-${props.environment}`,
      secretStringValue: cdk.SecretValue.unsafePlainText(
        "<dummy-value-that-is-at-least-16-character-long>",
      ),
    });
  }
}
