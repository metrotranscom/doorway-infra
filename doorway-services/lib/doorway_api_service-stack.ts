import * as cdk from "aws-cdk-lib";
import { ISubnet, SecurityGroup, Subnet } from "aws-cdk-lib/aws-ec2";
import {
  Cluster,
  Compatibility,
  ContainerImage,
  FargateService,
  LogDrivers,
  NetworkMode,
  Protocol,
  Secret,
  TaskDefinition,
} from "aws-cdk-lib/aws-ecs";
//import * as ecs from "aws-cdk-lib/aws-ecs";
import * as elb from "aws-cdk-lib/aws-elasticloadbalancingv2";
import {
  ManagedPolicy,
  PolicyStatement,
  Role,
  ServicePrincipal,
} from "aws-cdk-lib/aws-iam";
import { LogGroup } from "aws-cdk-lib/aws-logs";
import { ARecord, HostedZone, RecordTarget } from "aws-cdk-lib/aws-route53";
import { LoadBalancerTarget } from "aws-cdk-lib/aws-route53-targets";
import { Bucket } from "aws-cdk-lib/aws-s3";
import * as secret from "aws-cdk-lib/aws-secretsmanager";
import { EmailIdentity } from "aws-cdk-lib/aws-ses";
import { StringParameter } from "aws-cdk-lib/aws-ssm";
export interface DoorwayApiServiceStackProps extends cdk.StackProps {
  environment: string;
  env: {
    account: string;
    region: string;
  };
  /**
   * Version of the CDK Bootstrap resources in this environment, automatically retrieved from SSM Parameter Store. [cdk:skip]
   * @default '/cdk-bootstrap/hnb659fds/version'
   */
  readonly bootstrapVersion?: string;
}
export class DoorwayApiServiceStack extends cdk.Stack {
  public constructor(
    scope: cdk.App,
    id: string,
    props: DoorwayApiServiceStackProps = {
      environment: "dev",
      env: {
        account: process.env.CDK_DEFAULT_ACCOUNT || "none",
        region: process.env.CDK_DEFAULT_REGION || "none",
      },
    },
  ) {
    super(scope, id, props);
    // Applying default props
    props = {
      ...props,
      bootstrapVersion: new cdk.CfnParameter(this, "BootstrapVersion", {
        type: "AWS::SSM::Parameter::Value<String>",
        default:
          props.bootstrapVersion?.toString() ??
          "/cdk-bootstrap/hnb659fds/version",
        description:
          "Version of the CDK Bootstrap resources in this environment, automatically retrieved from SSM Parameter Store. [cdk:skip]",
      }).valueAsString,
    };
    const vpcId = StringParameter.fromStringParameterAttributes(this, "vpcId", {
      parameterName: `/doorway/${props.environment}/vpc/id`,
    }).stringValue;
    const vpc = cdk.aws_ec2.Vpc.fromVpcAttributes(this, "vpc", {
      vpcId: vpcId,
      availabilityZones: ["us-west-1a", "us-west-1c"],
    });
    const appSubnetIds: string[] = StringParameter.valueFromLookup(
      this,
      `/doorway/${props.environment}/vpc/appSubnets`,
    ).split(",");
    const appSubnets: ISubnet[] = [];
    appSubnetIds.forEach((id) => {
      appSubnets.push(Subnet.fromSubnetId(this, id, id));
    });
    const appTierPrivateSG = new SecurityGroup(
      this,
      `doorway-${props.environment}-private-app-sg`,
      {
        vpc: vpc,
        allowAllOutbound: true,
        description:
          "Private Application Security Group - used for internal communication",
        securityGroupName: `doorway-${props.environment}-private-app-sg`,
      },
    );
    const hostedZone = HostedZone.fromHostedZoneAttributes(
      this,
      "internalZone",
      {
        hostedZoneId: "Z084253138VJG63K273SM",
        zoneName: "housingbayarea.int",
      },
    );
    const privateLB = new elb.ApplicationLoadBalancer(
      this,
      `doorway-${props.environment}-private`,
      {
        vpc: vpc,
        internetFacing: false,
        securityGroup: appTierPrivateSG,
        vpcSubnets: {
          subnets: appSubnets,
        },
        loadBalancerName: `doorway-${props.environment}-private-lb`,
      },
    );
    const uploadsBucketName = StringParameter.fromStringParameterAttributes(
      this,
      "uploadsBucketName",
      {
        parameterName: `/doorway/${props.environment}/s3/uploadsBucketName`,
      },
    ).stringValue;
    const executionRole = new Role(this, "executionRole", {
      assumedBy: new ServicePrincipal("ecs-tasks.amazonaws.com"),
    });
    executionRole.addManagedPolicy(
      ManagedPolicy.fromAwsManagedPolicyName(
        "service-role/AmazonECSTaskExecutionRolePolicy",
      ),
    );
    executionRole.addManagedPolicy(
      ManagedPolicy.fromAwsManagedPolicyName("AmazonSSMReadOnlyAccess"),
    );
    executionRole.addManagedPolicy(
      ManagedPolicy.fromAwsManagedPolicyName("AmazonRDSReadOnlyAccess"),
    );
    executionRole.addManagedPolicy(
      ManagedPolicy.fromAwsManagedPolicyName(
        "AmazonEC2ContainerRegistryReadOnly",
      ),
    );
    const uploadsBucketArn = `arn:aws:s3:::${uploadsBucketName}`;
    const uploadsBucket = Bucket.fromBucketArn(
      this,
      "uploadsBucket",
      uploadsBucketArn,
    );
    uploadsBucket.grantReadWrite(executionRole);
    uploadsBucket.grantPut(executionRole);
    const sesIdentity = EmailIdentity.fromEmailIdentityName(
      this,
      "sesIdentity",
      "housingbayarea.org",
    );
    sesIdentity.grantSendEmail(executionRole);

    const policy = new PolicyStatement({
      actions: [
        "ses:SendEmail",
        "ses:SendRawEmail",
        "ses:SendTemplatedEmail",
        "ses:SendRawTemplatedEmail",
        "ses:SendBulkTemplatedEmail",
        "ses:UseConfiguration",
      ],
      resources: [
        sesIdentity.emailIdentityArn,
        `arn:aws:ses:${props.env.region}:${props.env.account}:configuration-set/dway-config-set`,
      ],
      conditions: {
        StringLike: {
          "ses:ConfigurationSetName": "dway-config-set",
        },
      },
    });
    executionRole.addToPolicy(policy);

    const minTasks = StringParameter.fromStringParameterAttributes(
      this,
      "minTasks",
      {
        parameterName: `/doorway/${props.environment}/internal-api/minimumTasks`,
      },
    ).stringValue;
    const task = new TaskDefinition(this, "task", {
      compatibility: Compatibility.FARGATE,
      cpu: "2048",
      memoryMiB: "4096",
      executionRole: executionRole,
      taskRole: executionRole,
      networkMode: NetworkMode.AWS_VPC,
    });
    task.addContainer("internal-api", {
      image: ContainerImage.fromRegistry(
        `364076391763.dkr.ecr.us-west-1.amazonaws.com/doorway-${props.environment}/backend:run`,
      ),
      cpu: 1,
      memoryLimitMiB: 1024,
      essential: true,
      logging: LogDrivers.awsLogs({
        streamPrefix: "internal-api",
        logGroup: LogGroup.fromLogGroupName(
          this,
          "logGroup",
          `doorway-${props.environment}-tasks`,
        ),
      }),
      secrets: {
        APP_SECRET: Secret.fromSecretsManager(
          secret.Secret.fromSecretNameV2(
            this,
            "app-secret",
            `app-secret-${props.environment}`,
          ),
        ),
        CLOUDINARY_KEY: Secret.fromSecretsManager(
          secret.Secret.fromSecretNameV2(
            this,
            "cloudinarykey",
            `CLOUDINARY_KEY`,
          ),
        ),
        GOOGLE_API_ID: Secret.fromSecretsManager(
          secret.Secret.fromSecretNameV2(this, "googleApiId", "GOOGLE_API_ID"),
        ),
        GOOGLE_API_EMAIL: Secret.fromSecretsManager(
          secret.Secret.fromSecretNameV2(
            this,
            "googleApiEmail",
            "GOOGLE_API_EMAIL",
          ),
        ),
        GOOGLE_API_KEY: Secret.fromSecretsManager(
          secret.Secret.fromSecretNameV2(
            this,
            "googleApiKey",
            "GOOGLE_API_KEY",
          ),
        ),
        GOVDELIVERY_API_URL: Secret.fromSecretsManager(
          secret.Secret.fromSecretNameV2(
            this,
            "govdeliveryApiUrl",
            "GOVDELIVERY_API_URL",
          ),
        ),
        GOVDELIVERY_PASSWORD: Secret.fromSecretsManager(
          secret.Secret.fromSecretNameV2(
            this,
            "govdeliveryPassword",
            "GOVDELIVERY_PASSWORD",
          ),
        ),
        GOVDELIVERY_USERNAME: Secret.fromSecretsManager(
          secret.Secret.fromSecretNameV2(
            this,
            "govdeliveryUsername",
            "GOVDELIVERY_USERNAME",
          ),
        ),
        EMAIL_API_KEY: Secret.fromSecretsManager(
          secret.Secret.fromSecretNameV2(this, "emailKey", "EMAIL_API_KEY"),
        ),
        DATABASE_URL: Secret.fromSecretsManager(
          secret.Secret.fromSecretNameV2(
            this,
            "dbUrl",
            StringParameter.fromStringParameterAttributes(
              this,
              "dbSecretName",
              {
                parameterName: `/doorway/${props.environment}/db/secret`,
              },
            ).stringValue,
          ),
          "uri",
        ),
        THROTTLE_LIMIT: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(
            this,
            "THROTTLE_LIMIT",
            {
              parameterName: `/doorway/${props.environment}/internal-api/THROTTLE_LIMIT`,
            },
          ),
        ),
        LOG_LEVEL: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(this, "LOG_LEVEL", {
            parameterName: `/doorway/${props.environment}/internal-api/LOG_LEVEL`,
          }),
        ),
        // LISTING_PROCESSING_CRON_STRING: Secret.fromSsmParameter(
        //   StringParameter.fromStringParameterAttributes(
        //     this,
        //     "LISTING_PROCESSING_CRON_STRING",
        //     {
        //       parameterName: `/doorway/${props.environment}/internal-api/LISTING_PROCESSING_CRON_STRING`,
        //     },
        //   ),
        // ),
        // LOTTERY_PROCESSING_CRON_STRING: Secret.fromSsmParameter(
        //   StringParameter.fromStringParameterAttributes(
        //     this,
        //     "LOTTERY_PROCESSING_CRON_STRING",
        //     {
        //       parameterName: `/doorway/${props.environment}/internal-api/LOTTERY_PROCESSING_CRON_STRING`,
        //     },
        //   ),
        // ),
        // LOTTERY_PUBLISH_PROCESSING_CRON_STRING: Secret.fromSsmParameter(
        //   StringParameter.fromStringParameterAttributes(
        //     this,
        //     "LOTTERY_PUBLISH_PROCESSING_CRON_STRING",
        //     {
        //       parameterName: `/doorway/${props.environment}/internal-api/LOTTERY_PUBLISH_PROCESSING_CRON_STRING`,
        //     },
        //   ),
        // ),
        // AFS_PROCESSING_CRON_STRING: Secret.fromSsmParameter(
        //   StringParameter.fromStringParameterAttributes(
        //     this,
        //     "AFS_PROCESSING_CRON_STRING",
        //     {
        //       parameterName: `/doorway/${props.environment}/internal-api/AFS_PROCESSING_CRON_STRING`,
        //     },
        //   ),
        // ),
        LOTTERY_DAYS_TILL_EXPIRY: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(
            this,
            "LOTTERY_DAYS_TILL_EXPIRY",
            {
              parameterName: `/doorway/${props.environment}/internal-api/LOTTERY_DAYS_TILL_EXPIRY`,
            },
          ),
        ),
        MFA_CODE_LENGTH: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(
            this,
            "MFA_CODE_LENGTH",
            {
              parameterName: `/doorway/${props.environment}/internal-api/MFA_CODE_LENGTH`,
            },
          ),
        ),
        MFA_CODE_VALID: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(
            this,
            "MFA_CODE_VALID",
            {
              parameterName: `/doorway/${props.environment}/internal-api/MFA_CODE_VALID`,
            },
          ),
        ),

        GOVDELIVERY_TOPIC: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(
            this,
            "GOVDELIVERY_TOPIC",
            {
              parameterName: `/doorway/${props.environment}/internal-api/GOVDELIVERY_TOPIC`,
            },
          ),
        ),
        TEMP_FILE_CLEAR_CRON_STRING: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(
            this,
            "TEMP_FILE_CLEAR_CRON_STRING",
            {
              parameterName: `/doorway/${props.environment}/internal-api/TEMP_FILE_CLEAR_CRON_STRING`,
            },
          ),
        ),
        PARTNERS_PORTAL_URL: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(
            this,
            "PARTNERS_PORTAL_URL",
            {
              parameterName: `/doorway/${props.environment}/internal-api/PARTNERS_PORTAL_URL`,
            },
          ),
        ),
        PARTNERS_BASE_URL: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(
            this,
            "PARTNERS_PORTAL_BASE_URL",
            {
              parameterName: `/doorway/${props.environment}/internal-api/PARTNERS_BASE_URL`,
            },
          ),
        ),
        THROTTLE_TTL: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(this, "THROTTLE_TTL", {
            parameterName: `/doorway/${props.environment}/internal-api/THROTTLE_TTL`,
          }),
        ),
        ASSET_FS_CONFIG_s3_REGION: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(
            this,
            "ASSET_FS_CONFIG_s3_REGION",
            {
              parameterName: `/doorway/${props.environment}/internal-api/ASSET_FS_CONFIG_s3_REGION`,
            },
          ),
        ),
        ASSET_FS_CONFIG_s3_URL_FORMAT: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(
            this,
            "ASSET_FS_CONFIG_s3_URL_FORMAT",
            {
              parameterName: `/doorway/${props.environment}/internal-api/ASSET_FS_CONFIG_s3_URL_FORMAT`,
            },
          ),
        ),
        ASSET_UPLOAD_MAX_SIZE: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(
            this,
            "ASSET_UPLOAD_MAX_SIZE",
            {
              parameterName: `/doorway/${props.environment}/internal-api/ASSET_UPLOAD_MAX_SIZE`,
            },
          ),
        ),
        AUTH_LOCK_LOGIN_COOLDOWN: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(
            this,
            "AUTH_LOCK_LOGIN_COOLDOWN",
            {
              parameterName: `/doorway/${props.environment}/internal-api/AUTH_LOCK_LOGIN_COOLDOWN`,
            },
          ),
        ),
        AUTH_LOCK_LOGIN_AFTER_FAILED_ATTEMPTS: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(
            this,
            "AUTH_LOCK_LOGIN_AFTER_FAILED_ATTEMPTS",
            {
              parameterName: `/doorway/${props.environment}/internal-api/AUTH_LOCK_LOGIN_AFTER_FAILED_ATTEMPTS`,
            },
          ),
        ),
        CORS_ORIGINS: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(this, "CORS_ORIGINS", {
            parameterName: `/doorway/${props.environment}/internal-api/CORS_ORIGINS`,
          }),
        ),
        ASSET_FS_CONFIG_s3_BUCKET: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(
            this,
            "ASSET_FS_CONFIG_s3_BUCKET",
            {
              parameterName: `/doorway/${props.environment}/s3/uploadsBucketName`,
            },
          ),
        ),
        DUPLICATES_CLOSE_DATE: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(
            this,
            "DUPLICATES_CLOSE_DATE",
            {
              parameterName: `/doorway/${props.environment}/internal-api/DUPLICATES_CLOSE_DATE`,
            },
          ),
        ),
        DUPLICATES_PROCESSING_CRON_STRING: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(
            this,
            "DUPLICATES_PROCESSING_CRON_STRING",
            {
              parameterName: `/doorway/${props.environment}/internal-api/DUPLICATES_PROCESSING_CRON_STRING`,
            },
          ),
        ),
        HTTPS_OFF: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(this, "HTTPS_OFF", {
            parameterName: `/doorway/${props.environment}/internal-api/HTTPS_OFF`,
          }),
        ),
        SAME_SITE: Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(this, "SAME_SITE", {
            parameterName: `/doorway/${props.environment}/internal-api/SAME_SITE`,
          }),
        ),
      },
      environment: {
        ASSET_FILE_SERVICE: "s3",
        LISTINGS_PROCESSING_QUERY: "/listings",
        PORT: "3100",
        SHOW_LM_LINKS: "TRUE",
        TIME_ZONE: "America/Los_Angeles",
        SHOW_DUPLICATES: "FALSE",
        NO_COLOR: "TRUE",
        ASSET_FS_CONFIG_s3_PATH_PREFIX: "",
      },
      entryPoint: [],
      portMappings: [
        {
          containerPort: 3100,
          protocol: Protocol.TCP,
          hostPort: 3100,
        },
      ],
    });
    const service = new FargateService(
      this,
      `doorway-${props.environment}-internal-api`,
      {
        taskDefinition: task,
        serviceName: `doorway-${props.environment}-internal-api`,
        cluster: Cluster.fromClusterAttributes(this, "default-cluster", {
          clusterName: `doorway-${props.environment}-default`,
          vpc: vpc,
        }),
        vpcSubnets: {
          subnets: appSubnets,
        },
        desiredCount: 2,
      },
    );
    const tg = new elb.ApplicationTargetGroup(this, "tg", {
      vpc: vpc,
      port: 3100,
      protocol: elb.ApplicationProtocol.HTTP,
      targetType: elb.TargetType.IP,
      healthCheck: {
        path: "/",
        protocol: elb.Protocol.HTTP,
        timeout: cdk.Duration.seconds(5),
        interval: cdk.Duration.seconds(30),
        healthyThresholdCount: 5,
        unhealthyThresholdCount: 2,
      },
    });
    service.attachToApplicationTargetGroup(tg);
    const scaling = service.autoScaleTaskCount({
      minCapacity: 2,
      maxCapacity: 10,
    });
    scaling.scaleOnCpuUtilization("CpuScaling", {
      targetUtilizationPercent: 80,
      scaleInCooldown: cdk.Duration.seconds(60),
      scaleOutCooldown: cdk.Duration.seconds(60),
    });
    const listener = privateLB.addListener("privateLbListener", {
      port: 80,
      protocol: elb.ApplicationProtocol.HTTP,
    });
    listener.addTargetGroups("privateLBTG", {
      targetGroups: [tg],
    });
    new ARecord(this, "internalAlias", {
      zone: hostedZone,
      recordName: `backend.${props.environment}`,
      target: RecordTarget.fromAlias(new LoadBalancerTarget(privateLB)),
    });
  }
}
