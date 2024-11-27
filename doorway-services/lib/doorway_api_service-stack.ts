import * as cdk from "aws-cdk-lib";
import { ISubnet, SecurityGroup, Subnet } from "aws-cdk-lib/aws-ec2";
import * as ecs from "aws-cdk-lib/aws-ecs";
import {
  ApplicationLoadBalancer,
  ApplicationProtocol,
  ApplicationTargetGroup,
  Protocol,
  TargetType,
} from "aws-cdk-lib/aws-elasticloadbalancingv2";
import { ManagedPolicy, Role, ServicePrincipal } from "aws-cdk-lib/aws-iam";
import { LogGroup } from "aws-cdk-lib/aws-logs";
import { ARecord, HostedZone, RecordTarget } from "aws-cdk-lib/aws-route53";
import { LoadBalancerTarget } from "aws-cdk-lib/aws-route53-targets";
import { Secret } from "aws-cdk-lib/aws-secretsmanager";
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
    const privateLB = new ApplicationLoadBalancer(
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
    const task = new ecs.TaskDefinition(this, "task", {
      compatibility: ecs.Compatibility.FARGATE,
      cpu: "512",
      memoryMiB: "1024",
      executionRole: executionRole,
      networkMode: ecs.NetworkMode.AWS_VPC,
    });
    const container = task.addContainer("internal-api", {
      image: ecs.ContainerImage.fromRegistry(
        `364076391763.dkr.ecr.us-west-1.amazonaws.com/doorway-${props.environment}/backend:run`,
      ),
      cpu: 512,
      memoryLimitMiB: 1024,
      essential: true,
      logging: ecs.LogDrivers.awsLogs({
        streamPrefix: "internal-api",
        logGroup: LogGroup.fromLogGroupName(
          this,
          "logGroup",
          `doorway-${props.environment}-tasks`,
        ),
      }),
      secrets: {
        APP_SECRET: ecs.Secret.fromSecretsManager(
          Secret.fromSecretNameV2(
            this,
            "appsecret",
            `app-secret-${props.environment}`,
          ),
        ),
        CLOUDINARY_KEY: ecs.Secret.fromSecretsManager(
          Secret.fromSecretNameV2(this, "cloudinarykey", `CLOUDINARY_KEY`),
        ),
        GOOGLE_API_ID: ecs.Secret.fromSecretsManager(
          Secret.fromSecretNameV2(this, "googleApiId", "GOOGLE_API_ID"),
        ),
        GOOGLE_API_EMAIL: ecs.Secret.fromSecretsManager(
          Secret.fromSecretNameV2(this, "googleApiEmail", "GOOGLE_API_EMAIL"),
        ),
        GOOGLE_API_KEY: ecs.Secret.fromSecretsManager(
          Secret.fromSecretNameV2(this, "googleApiKey", "GOOGLE_API_KEY"),
        ),
        GOVDELIVERY_API_URL: ecs.Secret.fromSecretsManager(
          Secret.fromSecretNameV2(
            this,
            "govdeliveryApiUrl",
            "GOVDELIVERY_API_URL",
          ),
        ),
        GOVDELIVERY_PASSWORD: ecs.Secret.fromSecretsManager(
          Secret.fromSecretNameV2(
            this,
            "govdeliveryPassword",
            "GOVDELIVERY_PASSWORD",
          ),
        ),
        GOVDELIVERY_USERNAME: ecs.Secret.fromSecretsManager(
          Secret.fromSecretNameV2(
            this,
            "govdeliveryUsername",
            "GOVDELIVERY_USERNAME",
          ),
        ),
        EMAIL_API_KEY: ecs.Secret.fromSecretsManager(
          Secret.fromSecretNameV2(this, "emailKey", "EMAIL_API_KEY"),
        ),
        DATABASE_URL: ecs.Secret.fromSecretsManager(
          Secret.fromSecretNameV2(
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
        THROTTLE_LIMIT: ecs.Secret.fromSsmParameter(
          StringParameter.fromStringParameterAttributes(this, "throttleLimit", {
            parameterName: `/doorway/${props.environment}/internal-api/THROTTLE_LIMIT`,
          }),
        ),
      },
      environment: {
        ASSET_FILE_SERVICE: "s3",
        LISTINGS_PROCESSING_QUERY: "/listings",
        PORT: "3100",
        SHOW_LM_LINKS: "TRUE",
        TIME_ZONE: "America/Los_Angeles",
        LISTING_PROCESSING_CRON_STRING: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/LISTING_PROCESSING_CRON_STRING`,
        ),
        LOTTERY_PROCESSING_CRON_STRING: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/LOTTERY_PROCESSING_CRON_STRING`,
        ),
        LOTTERY_PUBLISH__PROCESSING_CRON_STRING:
          StringParameter.valueFromLookup(
            this,
            `/doorway/${props.environment}/internal-api/LOTTERY_PUBLISH_PROCESSING_CRON_STRING`,
          ),
        LOTTERY_DAYS_TILL_EXPIRY: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/LOTTERY_DAYS_TILL_EXPIRY`,
        ),
        MFA_CODE_LENGTH: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/MFA_CODE_LENGTH`,
        ),
        MFA_CODE_VALID: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/MFA_CODE_VALID`,
        ),
        AFS_PROCESSING_CRON_STRING: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/AFS_PROCESSING_CRON_STRING`,
        ),
        GOVDELIVERY_TOPIC: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/GOVDELIVERY_TOPIC`,
        ),
        TEMP_FILE_CLEAR_CRON_STRING: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/TEMP_FILE_CLEAR_CRON_STRING`,
        ),
        SHOW_DUPLICATES: "FALSE",
        PARTNERS_PORTAL_URL: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/PARTNERS_PORTAL_URL`,
        ),
        PARTNERS_BASE_URL: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/PARTNERS_BASE_URL`,
        ),
        THROTTLE_TTL: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/THROTTLE_TTL`,
        ),
        ASSET_FS_CONFIG_s3_REGION: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/ASSET_FS_CONFIG_s3_REGION`,
        ),
        ASSET_FS_CONFIG_s3_URL_FORMAT: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/ASSET_FS_CONFIG_s3_URL_FORMAT`,
        ),
        NO_COLOR: "TRUE",
        ASSET_UPLOAD_MAX_SIZE: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/ASSET_UPLOAD_MAX_SIZE`,
        ),
        AUTH_LOCK_LOGIN_COOLDOWN: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/AUTH_LOCK_LOGIN_COOLDOWN`,
        ),
        AUTH_LOCK_LOGIN_AFTER_FAILED_ATTEMPTS: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/AUTH_LOCK_LOGIN_AFTER_FAILED_ATTEMPTS`,
        ),
        CORS_ORIGINS: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/CORS_ORIGINS`,
        ),
        ASSET_FS_CONFIG_s3_PATH_PREFIX: "",
        ASSET_FS_CONFIG_s3_BUCKET: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/s3/uploadsBucketName`,
        ),
        DUPLICATES_CLOSE_DATE: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/DUPLICATES_CLOSE_DATE`,
        ),
        DUPLICATES_PROCESSING_CRON_STRING: StringParameter.valueFromLookup(
          this,
          `/doorway/${props.environment}/internal-api/DUPLICATES_PROCESSING_CRON_STRING`,
        ),
      },
      entryPoint: [],
      portMappings: [
        {
          containerPort: 3100,
          protocol: ecs.Protocol.TCP,
          hostPort: 3100,
        },
      ],
    });
    const minTasks = StringParameter.fromStringParameterAttributes(
      this,
      "minTasks",
      {
        parameterName: `/doorway/${props.environment}/internal-api/minimumTasks`,
      },
    ).stringValue;
    const service = new ecs.FargateService(
      this,
      `doorway-${props.environment}-internal-api`,
      {
        taskDefinition: task,
        serviceName: `doorway-${props.environment}-internal-api`,
        cluster: ecs.Cluster.fromClusterAttributes(this, "default-cluster", {
          clusterName: `doorway-${props.environment}-default`,
          vpc: vpc,
        }),
        vpcSubnets: {
          subnets: appSubnets,
        },
        desiredCount: 1,
      },
    );
    const tg = new ApplicationTargetGroup(this, "tg", {
      vpc: vpc,
      port: 3100,
      protocol: ApplicationProtocol.HTTP,
      targetType: TargetType.IP,
      healthCheck: {
        path: "/",
        protocol: Protocol.HTTP,
        timeout: cdk.Duration.seconds(5),
        interval: cdk.Duration.seconds(30),
        healthyThresholdCount: 5,
        unhealthyThresholdCount: 2,
      },
    });
    service.attachToApplicationTargetGroup(tg);
    const listener = privateLB.addListener("privateLbListener", {
      port: 80,
      protocol: ApplicationProtocol.HTTP,
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
