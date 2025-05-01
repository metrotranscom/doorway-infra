"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DoorwayApiServiceStack = void 0;
const cdk = require("aws-cdk-lib");
const aws_ec2_1 = require("aws-cdk-lib/aws-ec2");
const aws_ecs_1 = require("aws-cdk-lib/aws-ecs");
//import * as ecs from "aws-cdk-lib/aws-ecs";
const elb = require("aws-cdk-lib/aws-elasticloadbalancingv2");
const aws_iam_1 = require("aws-cdk-lib/aws-iam");
const aws_logs_1 = require("aws-cdk-lib/aws-logs");
const aws_route53_1 = require("aws-cdk-lib/aws-route53");
const aws_route53_targets_1 = require("aws-cdk-lib/aws-route53-targets");
const aws_s3_1 = require("aws-cdk-lib/aws-s3");
const secret = require("aws-cdk-lib/aws-secretsmanager");
const aws_ses_1 = require("aws-cdk-lib/aws-ses");
const aws_ssm_1 = require("aws-cdk-lib/aws-ssm");
class DoorwayApiServiceStack extends cdk.Stack {
    constructor(scope, id, props = {
        environment: "dev",
        env: {
            account: process.env.CDK_DEFAULT_ACCOUNT || "none",
            region: process.env.CDK_DEFAULT_REGION || "none",
        },
    }) {
        super(scope, id, props);
        // Applying default props
        props = {
            ...props,
            bootstrapVersion: new cdk.CfnParameter(this, "BootstrapVersion", {
                type: "AWS::SSM::Parameter::Value<String>",
                default: props.bootstrapVersion?.toString() ??
                    "/cdk-bootstrap/hnb659fds/version",
                description: "Version of the CDK Bootstrap resources in this environment, automatically retrieved from SSM Parameter Store. [cdk:skip]",
            }).valueAsString,
        };
        const vpcId = aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "vpcId", {
            parameterName: `/doorway/${props.environment}/vpc/id`,
        }).stringValue;
        const vpc = cdk.aws_ec2.Vpc.fromVpcAttributes(this, "vpc", {
            vpcId: vpcId,
            availabilityZones: ["us-west-1a", "us-west-1c"],
        });
        const appSubnetIds = aws_ssm_1.StringParameter.valueFromLookup(this, `/doorway/${props.environment}/vpc/appSubnets`).split(",");
        const appSubnets = [];
        appSubnetIds.forEach((id) => {
            appSubnets.push(aws_ec2_1.Subnet.fromSubnetId(this, id, id));
        });
        const appTierPrivateSG = new aws_ec2_1.SecurityGroup(this, `doorway-${props.environment}-private-app-sg`, {
            vpc: vpc,
            allowAllOutbound: true,
            description: "Private Application Security Group - used for internal communication",
            securityGroupName: `doorway-${props.environment}-private-app-sg`,
        });
        const hostedZone = aws_route53_1.HostedZone.fromHostedZoneAttributes(this, "internalZone", {
            hostedZoneId: "Z084253138VJG63K273SM",
            zoneName: "housingbayarea.int",
        });
        const privateLB = new elb.ApplicationLoadBalancer(this, `doorway-${props.environment}-private`, {
            vpc: vpc,
            internetFacing: false,
            securityGroup: appTierPrivateSG,
            vpcSubnets: {
                subnets: appSubnets,
            },
            loadBalancerName: `doorway-${props.environment}-private-lb`,
        });
        const uploadsBucketName = aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "uploadsBucketName", {
            parameterName: `/doorway/${props.environment}/s3/uploadsBucketName`,
        }).stringValue;
        const executionRole = new aws_iam_1.Role(this, "executionRole", {
            assumedBy: new aws_iam_1.ServicePrincipal("ecs-tasks.amazonaws.com"),
        });
        executionRole.addManagedPolicy(aws_iam_1.ManagedPolicy.fromAwsManagedPolicyName("service-role/AmazonECSTaskExecutionRolePolicy"));
        executionRole.addManagedPolicy(aws_iam_1.ManagedPolicy.fromAwsManagedPolicyName("AmazonSSMReadOnlyAccess"));
        executionRole.addManagedPolicy(aws_iam_1.ManagedPolicy.fromAwsManagedPolicyName("AmazonRDSReadOnlyAccess"));
        executionRole.addManagedPolicy(aws_iam_1.ManagedPolicy.fromAwsManagedPolicyName("AmazonEC2ContainerRegistryReadOnly"));
        const uploadsBucketArn = `arn:aws:s3:::${uploadsBucketName}`;
        const uploadsBucket = aws_s3_1.Bucket.fromBucketArn(this, "uploadsBucket", uploadsBucketArn);
        uploadsBucket.grantReadWrite(executionRole);
        uploadsBucket.grantPut(executionRole);
        const sesIdentity = aws_ses_1.EmailIdentity.fromEmailIdentityName(this, "sesIdentity", "housingbayarea.org");
        sesIdentity.grantSendEmail(executionRole);
        const policy = new aws_iam_1.PolicyStatement({
            actions: [
                "ses:SendEmail",
                "ses:SendRawEmail",
                "ses:SendTemplatedEmail",
                "ses:SendRawTemplatedEmail",
                "ses:SendBulkTemplatedEmail",
                "ses:UseConfiguration",
                "ses:SendBulkEmail",
            ],
            resources: [
                sesIdentity.emailIdentityArn,
                `arn:aws:ses:${props.env.region}:${props.env.account}:configuration-set/dway-config-set`,
                `arn:aws:ses:${props.env.region}:${props.env.account}:identity/*`,
            ],
        });
        executionRole.addToPolicy(policy);
        const minTasks = aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "minTasks", {
            parameterName: `/doorway/${props.environment}/internal-api/minimumTasks`,
        }).stringValue;
        const task = new aws_ecs_1.TaskDefinition(this, "task", {
            compatibility: aws_ecs_1.Compatibility.FARGATE,
            cpu: "2048",
            memoryMiB: "4096",
            executionRole: executionRole,
            taskRole: executionRole,
            networkMode: aws_ecs_1.NetworkMode.AWS_VPC,
        });
        task.addContainer("internal-api", {
            image: aws_ecs_1.ContainerImage.fromRegistry(`364076391763.dkr.ecr.us-west-1.amazonaws.com/doorway-${props.environment}/backend:run`),
            cpu: 1,
            memoryLimitMiB: 1024,
            essential: true,
            logging: aws_ecs_1.LogDrivers.awsLogs({
                streamPrefix: "internal-api",
                logGroup: aws_logs_1.LogGroup.fromLogGroupName(this, "logGroup", `doorway-${props.environment}-tasks`),
            }),
            secrets: {
                APP_SECRET: aws_ecs_1.Secret.fromSecretsManager(secret.Secret.fromSecretNameV2(this, "app-secret", `app-secret-${props.environment}`)),
                CLOUDINARY_KEY: aws_ecs_1.Secret.fromSecretsManager(secret.Secret.fromSecretNameV2(this, "cloudinarykey", `CLOUDINARY_KEY`)),
                GOOGLE_API_ID: aws_ecs_1.Secret.fromSecretsManager(secret.Secret.fromSecretNameV2(this, "googleApiId", "GOOGLE_API_ID")),
                GOOGLE_API_EMAIL: aws_ecs_1.Secret.fromSecretsManager(secret.Secret.fromSecretNameV2(this, "googleApiEmail", "GOOGLE_API_EMAIL")),
                GOOGLE_API_KEY: aws_ecs_1.Secret.fromSecretsManager(secret.Secret.fromSecretNameV2(this, "googleApiKey", "GOOGLE_API_KEY")),
                GOVDELIVERY_API_URL: aws_ecs_1.Secret.fromSecretsManager(secret.Secret.fromSecretNameV2(this, "govdeliveryApiUrl", "GOVDELIVERY_API_URL")),
                GOVDELIVERY_PASSWORD: aws_ecs_1.Secret.fromSecretsManager(secret.Secret.fromSecretNameV2(this, "govdeliveryPassword", "GOVDELIVERY_PASSWORD")),
                GOVDELIVERY_USERNAME: aws_ecs_1.Secret.fromSecretsManager(secret.Secret.fromSecretNameV2(this, "govdeliveryUsername", "GOVDELIVERY_USERNAME")),
                EMAIL_API_KEY: aws_ecs_1.Secret.fromSecretsManager(secret.Secret.fromSecretNameV2(this, "emailKey", "EMAIL_API_KEY")),
                DATABASE_URL: aws_ecs_1.Secret.fromSecretsManager(secret.Secret.fromSecretNameV2(this, "dbUrl", aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "dbSecretName", {
                    parameterName: `/doorway/${props.environment}/db/secret`,
                }).stringValue), "uri"),
                THROTTLE_LIMIT: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "THROTTLE_LIMIT", {
                    parameterName: `/doorway/${props.environment}/internal-api/THROTTLE_LIMIT`,
                })),
                LOG_LEVEL: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "LOG_LEVEL", {
                    parameterName: `/doorway/${props.environment}/internal-api/LOG_LEVEL`,
                })),
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
                LOTTERY_DAYS_TILL_EXPIRY: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "LOTTERY_DAYS_TILL_EXPIRY", {
                    parameterName: `/doorway/${props.environment}/internal-api/LOTTERY_DAYS_TILL_EXPIRY`,
                })),
                MFA_CODE_LENGTH: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "MFA_CODE_LENGTH", {
                    parameterName: `/doorway/${props.environment}/internal-api/MFA_CODE_LENGTH`,
                })),
                MFA_CODE_VALID: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "MFA_CODE_VALID", {
                    parameterName: `/doorway/${props.environment}/internal-api/MFA_CODE_VALID`,
                })),
                GOVDELIVERY_TOPIC: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "GOVDELIVERY_TOPIC", {
                    parameterName: `/doorway/${props.environment}/internal-api/GOVDELIVERY_TOPIC`,
                })),
                TEMP_FILE_CLEAR_CRON_STRING: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "TEMP_FILE_CLEAR_CRON_STRING", {
                    parameterName: `/doorway/${props.environment}/internal-api/TEMP_FILE_CLEAR_CRON_STRING`,
                })),
                PARTNERS_PORTAL_URL: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "PARTNERS_PORTAL_URL", {
                    parameterName: `/doorway/${props.environment}/internal-api/PARTNERS_PORTAL_URL`,
                })),
                PARTNERS_BASE_URL: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "PARTNERS_PORTAL_BASE_URL", {
                    parameterName: `/doorway/${props.environment}/internal-api/PARTNERS_BASE_URL`,
                })),
                THROTTLE_TTL: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "THROTTLE_TTL", {
                    parameterName: `/doorway/${props.environment}/internal-api/THROTTLE_TTL`,
                })),
                ASSET_FS_CONFIG_s3_REGION: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "ASSET_FS_CONFIG_s3_REGION", {
                    parameterName: `/doorway/${props.environment}/internal-api/ASSET_FS_CONFIG_s3_REGION`,
                })),
                ASSET_FS_CONFIG_s3_URL_FORMAT: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "ASSET_FS_CONFIG_s3_URL_FORMAT", {
                    parameterName: `/doorway/${props.environment}/internal-api/ASSET_FS_CONFIG_s3_URL_FORMAT`,
                })),
                ASSET_UPLOAD_MAX_SIZE: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "ASSET_UPLOAD_MAX_SIZE", {
                    parameterName: `/doorway/${props.environment}/internal-api/ASSET_UPLOAD_MAX_SIZE`,
                })),
                AUTH_LOCK_LOGIN_COOLDOWN: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "AUTH_LOCK_LOGIN_COOLDOWN", {
                    parameterName: `/doorway/${props.environment}/internal-api/AUTH_LOCK_LOGIN_COOLDOWN`,
                })),
                AUTH_LOCK_LOGIN_AFTER_FAILED_ATTEMPTS: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "AUTH_LOCK_LOGIN_AFTER_FAILED_ATTEMPTS", {
                    parameterName: `/doorway/${props.environment}/internal-api/AUTH_LOCK_LOGIN_AFTER_FAILED_ATTEMPTS`,
                })),
                CORS_ORIGINS: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "CORS_ORIGINS", {
                    parameterName: `/doorway/${props.environment}/internal-api/CORS_ORIGINS`,
                })),
                ASSET_FS_CONFIG_s3_BUCKET: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "ASSET_FS_CONFIG_s3_BUCKET", {
                    parameterName: `/doorway/${props.environment}/s3/uploadsBucketName`,
                })),
                DUPLICATES_CLOSE_DATE: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "DUPLICATES_CLOSE_DATE", {
                    parameterName: `/doorway/${props.environment}/internal-api/DUPLICATES_CLOSE_DATE`,
                })),
                DUPLICATES_PROCESSING_CRON_STRING: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "DUPLICATES_PROCESSING_CRON_STRING", {
                    parameterName: `/doorway/${props.environment}/internal-api/DUPLICATES_PROCESSING_CRON_STRING`,
                })),
                HTTPS_OFF: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "HTTPS_OFF", {
                    parameterName: `/doorway/${props.environment}/internal-api/HTTPS_OFF`,
                })),
                SAME_SITE: aws_ecs_1.Secret.fromSsmParameter(aws_ssm_1.StringParameter.fromStringParameterAttributes(this, "SAME_SITE", {
                    parameterName: `/doorway/${props.environment}/internal-api/SAME_SITE`,
                })),

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
                    protocol: aws_ecs_1.Protocol.TCP,
                    hostPort: 3100,
                },
            ],
        });
        const service = new aws_ecs_1.FargateService(this, `doorway-${props.environment}-internal-api`, {
            taskDefinition: task,
            serviceName: `doorway-${props.environment}-internal-api`,
            cluster: aws_ecs_1.Cluster.fromClusterAttributes(this, "default-cluster", {
                clusterName: `doorway-${props.environment}-default`,
                vpc: vpc,
            }),
            vpcSubnets: {
                subnets: appSubnets,
            },
            desiredCount: 2,
        });
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
        new aws_route53_1.ARecord(this, "internalAlias", {
            zone: hostedZone,
            recordName: `backend.${props.environment}`,
            target: aws_route53_1.RecordTarget.fromAlias(new aws_route53_targets_1.LoadBalancerTarget(privateLB)),
        });
    }
}
exports.DoorwayApiServiceStack = DoorwayApiServiceStack;
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiZG9vcndheV9hcGlfc2VydmljZS1zdGFjay5qcyIsInNvdXJjZVJvb3QiOiIiLCJzb3VyY2VzIjpbImRvb3J3YXlfYXBpX3NlcnZpY2Utc3RhY2sudHMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6Ijs7O0FBQUEsbUNBQW1DO0FBQ25DLGlEQUFxRTtBQUNyRSxpREFVNkI7QUFDN0IsNkNBQTZDO0FBQzdDLDhEQUE4RDtBQUM5RCxpREFLNkI7QUFDN0IsbURBQWdEO0FBQ2hELHlEQUE0RTtBQUM1RSx5RUFBcUU7QUFDckUsK0NBQTRDO0FBQzVDLHlEQUF5RDtBQUN6RCxpREFBb0Q7QUFDcEQsaURBQXNEO0FBYXRELE1BQWEsc0JBQXVCLFNBQVEsR0FBRyxDQUFDLEtBQUs7SUFDbkQsWUFDRSxLQUFjLEVBQ2QsRUFBVSxFQUNWLFFBQXFDO1FBQ25DLFdBQVcsRUFBRSxLQUFLO1FBQ2xCLEdBQUcsRUFBRTtZQUNILE9BQU8sRUFBRSxPQUFPLENBQUMsR0FBRyxDQUFDLG1CQUFtQixJQUFJLE1BQU07WUFDbEQsTUFBTSxFQUFFLE9BQU8sQ0FBQyxHQUFHLENBQUMsa0JBQWtCLElBQUksTUFBTTtTQUNqRDtLQUNGO1FBRUQsS0FBSyxDQUFDLEtBQUssRUFBRSxFQUFFLEVBQUUsS0FBSyxDQUFDLENBQUM7UUFDeEIseUJBQXlCO1FBQ3pCLEtBQUssR0FBRztZQUNOLEdBQUcsS0FBSztZQUNSLGdCQUFnQixFQUFFLElBQUksR0FBRyxDQUFDLFlBQVksQ0FBQyxJQUFJLEVBQUUsa0JBQWtCLEVBQUU7Z0JBQy9ELElBQUksRUFBRSxvQ0FBb0M7Z0JBQzFDLE9BQU8sRUFDTCxLQUFLLENBQUMsZ0JBQWdCLEVBQUUsUUFBUSxFQUFFO29CQUNsQyxrQ0FBa0M7Z0JBQ3BDLFdBQVcsRUFDVCwwSEFBMEg7YUFDN0gsQ0FBQyxDQUFDLGFBQWE7U0FDakIsQ0FBQztRQUNGLE1BQU0sS0FBSyxHQUFHLHlCQUFlLENBQUMsNkJBQTZCLENBQUMsSUFBSSxFQUFFLE9BQU8sRUFBRTtZQUN6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QUFFLENBQUM7YUFDM0I7U0FDRixDQUFDLENBQUM7UUFDSCxPQUFPLENBQUMsOEJBQThCLENBQUMsRUFBRSxDQUFDLENBQUM7UUFDM0MsTUFBTSxPQUFPLEdBQUcsT0FBTyxDQUFDLGtCQUFrQixDQUFDO1lBQ3pDLFdBQVcsRUFBRSxDQUFDO1lBQ2QsV0FBVyxFQUFFLEVBQUU7U0FDaEIsQ0FBQyxDQUFDO1FBQ0gsT0FBTyxDQUFDLHFCQUFxQixDQUFDLFlBQVksRUFBRTtZQUMxQyx3QkFBd0IsRUFBRSxFQUFFO1lBQzVCLGVBQWUsRUFBRSxHQUFHLENBQUMsUUFBUSxDQUFDLE9BQU8sQ0FBQyxFQUFFLENBQUM7WUFDekMsZ0JBQWdCLEVBQUUsR0FBRyxDQUFDLFFBQVEsQ0FBQyxPQUFPLENBQUMsRUFBRSxDQUFDO1NBQzNDLENBQUMsQ0FBQztRQUNILE1BQU0sUUFBUSxHQUFHLFNBQVMsQ0FBQyxXQUFXLENBQUMsbUJBQW1CLEVBQUU7WUFDMUQsSUFBSSxFQUFFLEVBQUU7WUFDUixRQUFRLEVBQUUsR0FBRyxDQUFDLG1CQUFtQixDQUFDLElBQUk7U0FDdkMsQ0FBQyxDQUFDO1FBQ0gsUUFBUSxDQUFDLGVBQWUsQ0FBQyxhQUFhLEVBQUU7WUFDdEMsWUFBWSxFQUFFLENBQUMsRUFBRSxDQUFDO1NBQ25CLENBQUMsQ0FBQztRQUNILElBQUkscUJBQU8sQ0FBQyxJQUFJLEVBQUUsZUFBZSxFQUFFO1lBQ2pDLElBQUksRUFBRSxVQUFVO1lBQ2hCLFVBQVUsRUFBRSxXQUFXLEtBQUssQ0FBQyxXQUFXLEVBQUU7WUFDMUMsTUFBTSxFQUFFLDBCQUFZLENBQUMsU0FBUyxDQUFDLElBQUksd0NBQWtCLENBQUMsU0FBUyxDQUFDLENBQUM7U0FDbEUsQ0FBQyxDQUFDO0lBQ0wsQ0FBQztDQUNGO0FBOWZELHdEQThmQyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCAqIGFzIGNkayBmcm9tIFwiYXdzLWNkay1saWJcIjtcbmltcG9ydCB7IElTdWJuZXQsIFNlY3VyaXR5R3JvdXAsIFN1Ym5ldCB9IGZyb20gXCJhd3MtY2RrLWxpYi9hd3MtZWMyXCI7XG5pbXBvcnQge1xuICBDbHVzdGVyLFxuICBDb21wYXRpYmlsaXR5LFxuICBDb250YWluZXJJbWFnZSxcbiAgRmFyZ2F0ZVNlcnZpY2UsXG4gIExvZ0RyaXZlcnMsXG4gIE5ldHdvcmtNb2RlLFxuICBQcm90b2NvbCxcbiAgU2VjcmV0LFxuICBUYXNrRGVmaW5pdGlvbixcbn0gZnJvbSBcImF3cy1jZGstbGliL2F3cy1lY3NcIjtcbi8vaW1wb3J0ICogYXMgZWNzIGZyb20gXCJhd3MtY2RrLWxpYi9hd3MtZWNzXCI7XG5pbXBvcnQgKiBhcyBlbGIgZnJvbSBcImF3cy1jZGstbGliL2F3cy1lbGFzdGljbG9hZGJhbGFuY2luZ3YyXCI7XG5pbXBvcnQge1xuICBNYW5hZ2VkUG9saWN5LFxuICBQb2xpY3lTdGF0ZW1lbnQsXG4gIFJvbGUsXG4gIFNlcnZpY2VQcmluY2lwYWwsXG59IGZyb20gXCJhd3MtY2RrLWxpYi9hd3MtaWFtXCI7XG5pbXBvcnQgeyBMb2dHcm91cCB9IGZyb20gXCJhd3MtY2RrLWxpYi9hd3MtbG9nc1wiO1xuaW1wb3J0IHsgQVJlY29yZCwgSG9zdGVkWm9uZSwgUmVjb3JkVGFyZ2V0IH0gZnJvbSBcImF3cy1jZGstbGliL2F3cy1yb3V0ZTUzXCI7XG5pbXBvcnQgeyBMb2FkQmFsYW5jZXJUYXJnZXQgfSBmcm9tIFwiYXdzLWNkay1saWIvYXdzLXJvdXRlNTMtdGFyZ2V0c1wiO1xuaW1wb3J0IHsgQnVja2V0IH0gZnJvbSBcImF3cy1jZGstbGliL2F3cy1zM1wiO1xuaW1wb3J0ICogYXMgc2VjcmV0IGZyb20gXCJhd3MtY2RrLWxpYi9hd3Mtc2VjcmV0c21hbmFnZXJcIjtcbmltcG9ydCB7IEVtYWlsSWRlbnRpdHkgfSBmcm9tIFwiYXdzLWNkay1saWIvYXdzLXNlc1wiO1xuaW1wb3J0IHsgU3RyaW5nUGFyYW1ldGVyIH0gZnJvbSBcImF3cy1jZGstbGliL2F3cy1zc21cIjtcbmV4cG9ydCBpbnRlcmZhY2UgRG9vcndheUFwaVNlcnZpY2VTdGFja1Byb3BzIGV4dGVuZHMgY2RrLlN0YWNrUHJvcHMge1xuICBlbnZpcm9ubWVudDogc3RyaW5nO1xuICBlbnY6IHtcbiAgICBhY2NvdW50OiBzdHJpbmc7XG4gICAgcmVnaW9uOiBzdHJpbmc7XG4gIH07XG4gIC8qKlxuICAgKiBWZXJzaW9uIG9mIHRoZSBDREsgQm9vdHN0cmFwIHJlc291cmNlcyBpbiB0aGlzIGVudmlyb25tZW50LCBhdXRvbWF0aWNhbGx5IHJldHJpZXZlZCBmcm9tIFNTTSBQYXJhbWV0ZXIgU3RvcmUuIFtjZGs6c2tpcF1cbiAgICogQGRlZmF1bHQgJy9jZGstYm9vdHN0cmFwL2huYjY1OWZkcy92ZXJzaW9uJ1xuICAgKi9cbiAgcmVhZG9ubHkgYm9vdHN0cmFwVmVyc2lvbj86IHN0cmluZztcbn1cbmV4cG9ydCBjbGFzcyBEb29yd2F5QXBpU2VydmljZVN0YWNrIGV4dGVuZHMgY2RrLlN0YWNrIHtcbiAgcHVibGljIGNvbnN0cnVjdG9yKFxuICAgIHNjb3BlOiBjZGsuQXBwLFxuICAgIGlkOiBzdHJpbmcsXG4gICAgcHJvcHM6IERvb3J3YXlBcGlTZXJ2aWNlU3RhY2tQcm9wcyA9IHtcbiAgICAgIGVudmlyb25tZW50OiBcImRldlwiLFxuICAgICAgZW52OiB7XG4gICAgICAgIGFjY291bnQ6IHByb2Nlc3MuZW52LkNES19ERUZBVUxUX0FDQ09VTlQgfHwgXCJub25lXCIsXG4gICAgICAgIHJlZ2lvbjogcHJvY2Vzcy5lbnYuQ0RLX0RFRkFVTFRfUkVHSU9OIHx8IFwibm9uZVwiLFxuICAgICAgfSxcbiAgICB9LFxuICApIHtcbiAgICBzdXBlcihzY29wZSwgaWQsIHByb3BzKTtcbiAgICAvLyBBcHBseWluZyBkZWZhdWx0IHByb3BzXG4gICAgcHJvcHMgPSB7XG4gICAgICAuLi5wcm9wcyxcbiAgICAgIGJvb3RzdHJhcFZlcnNpb246IG5ldyBjZGsuQ2ZuUGFyYW1ldGVyKHRoaXMsIFwiQm9vdHN0cmFwVmVyc2lvblwiLCB7XG4gICAgICAgIHR5cGU6IFwiQVdTOjpTU006OlBhcmFtZXRlcjo6VmFsdWU8U3RyaW5nPlwiLFxuICAgICAgICBkZWZhdWx0OlxuICAgICAgICAgIHByb3BzLmJvb3RzdHJhcFZlcnNpb24/LnRvU3RyaW5nKCkgPz9cbiAgICAgICAgICBcIi9jZGstYm9vdHN0cmFwL2huYjY1OWZkcy92ZXJzaW9uXCIsXG4gICAgICAgIGRlc2NyaXB0aW9uOlxuICAgICAgICAgIFwiVmVyc2lvbiBvZiB0aGUgQ0RLIEJvb3RzdHJhcCByZXNvdXJjZXMgaW4gdGhpcyBlbnZpcm9ubWVudCwgYXV0b21hdGljYWxseSByZXRyaWV2ZWQgZnJvbSBTU00gUGFyYW1ldGVyIFN0b3JlLiBbY2RrOnNraXBdXCIsXG4gICAgICB9KS52YWx1ZUFzU3RyaW5nLFxuICAgIH07XG4gICAgY29uc3QgdnBjSWQgPSBTdHJpbmdQYXJhbWV0ZXIuZnJvbVN0cmluZ1BhcmFtZXRlckF0dHJpYnV0ZXModGhpcywgXCJ2cGNJZFwiLCB7XG4gICAgICBwYXJhbWV0ZXJOYW1lOiBgL2Rvb3J3YXkvJHtwcm9wcy5lbnZpcm9ubWVudH0vdnBjL2lkYCxcbiAgICB9KS5zdHJpbmdWYWx1ZTtcbiAgICBjb25zdCB2cGMgPSBjZGsuYXdzX2VjMi5WcGMuZnJvbVZwY0F0dHJpYnV0ZXModGhpcywgXCJ2cGNcIiwge1xuICAgICAgdnBjSWQ6IHZwY0lkLFxuICAgICAgYXZhaWxhYmlsaXR5Wm9uZXM6IFtcInVzLXdlc3QtMWFcIiwgXCJ1cy13ZXN0LTFjXCJdLFxuICAgIH0pO1xuICAgIGNvbnN0IGFwcFN1Ym5ldElkczogc3RyaW5nW10gPSBTdHJpbmdQYXJhbWV0ZXIudmFsdWVGcm9tTG9va3VwKFxuICAgICAgdGhpcyxcbiAgICAgIGAvZG9vcndheS8ke3Byb3BzLmVudmlyb25tZW50fS92cGMvYXBwU3VibmV0c2AsXG4gICAgKS5zcGxpdChcIixcIik7XG4gICAgY29uc3QgYXBwU3VibmV0czogSVN1Ym5ldFtdID0gW107XG4gICAgYXBwU3VibmV0SWRzLmZvckVhY2goKGlkKSA9PiB7XG4gICAgICBhcHBTdWJuZXRzLnB1c2goU3VibmV0LmZyb21TdWJuZXRJZCh0aGlzLCBpZCwgaWQpKTtcbiAgICB9KTtcbiAgICBjb25zdCBhcHBUaWVyUHJpdmF0ZVNHID0gbmV3IFNlY3VyaXR5R3JvdXAoXG4gICAgICB0aGlzLFxuICAgICAgYGRvb3J3YXktJHtwcm9wcy5lbnZpcm9ubWVudH0tcHJpdmF0ZS1hcHAtc2dgLFxuICAgICAge1xuICAgICAgICB2cGM6IHZwYyxcbiAgICAgICAgYWxsb3dBbGxPdXRib3VuZDogdHJ1ZSxcbiAgICAgICAgZGVzY3JpcHRpb246XG4gICAgICAgICAgXCJQcml2YXRlIEFwcGxpY2F0aW9uIFNlY3VyaXR5IEdyb3VwIC0gdXNlZCBmb3IgaW50ZXJuYWwgY29tbXVuaWNhdGlvblwiLFxuICAgICAgICBzZWN1cml0eUdyb3VwTmFtZTogYGRvb3J3YXktJHtwcm9wcy5lbnZpcm9ubWVudH0tcHJpdmF0ZS1hcHAtc2dgLFxuICAgICAgfSxcbiAgICApO1xuICAgIGNvbnN0IGhvc3RlZFpvbmUgPSBIb3N0ZWRab25lLmZyb21Ib3N0ZWRab25lQXR0cmlidXRlcyhcbiAgICAgIHRoaXMsXG4gICAgICBcImludGVybmFsWm9uZVwiLFxuICAgICAge1xuICAgICAgICBob3N0ZWRab25lSWQ6IFwiWjA4NDI1MzEzOFZKRzYzSzI3M1NNXCIsXG4gICAgICAgIHpvbmVOYW1lOiBcImhvdXNpbmdiYXlhcmVhLmludFwiLFxuICAgICAgfSxcbiAgICApO1xuICAgIGNvbnN0IHByaXZhdGVMQiA9IG5ldyBlbGIuQXBwbGljYXRpb25Mb2FkQmFsYW5jZXIoXG4gICAgICB0aGlzLFxuICAgICAgYGRvb3J3YXktJHtwcm9wcy5lbnZpcm9ubWVudH0tcHJpdmF0ZWAsXG4gICAgICB7XG4gICAgICAgIHZwYzogdnBjLFxuICAgICAgICBpbnRlcm5ldEZhY2luZzogZmFsc2UsXG4gICAgICAgIHNlY3VyaXR5R3JvdXA6IGFwcFRpZXJQcml2YXRlU0csXG4gICAgICAgIHZwY1N1Ym5ldHM6IHtcbiAgICAgICAgICBzdWJuZXRzOiBhcHBTdWJuZXRzLFxuICAgICAgICB9LFxuICAgICAgICBsb2FkQmFsYW5jZXJOYW1lOiBgZG9vcndheS0ke3Byb3BzLmVudmlyb25tZW50fS1wcml2YXRlLWxiYCxcbiAgICAgIH0sXG4gICAgKTtcbiAgICBjb25zdCB1cGxvYWRzQnVja2V0TmFtZSA9IFN0cmluZ1BhcmFtZXRlci5mcm9tU3RyaW5nUGFyYW1ldGVyQXR0cmlidXRlcyhcbiAgICAgIHRoaXMsXG4gICAgICBcInVwbG9hZHNCdWNrZXROYW1lXCIsXG4gICAgICB7XG4gICAgICAgIHBhcmFtZXRlck5hbWU6IGAvZG9vcndheS8ke3Byb3BzLmVudmlyb25tZW50fS9zMy91cGxvYWRzQnVja2V0TmFtZWAsXG4gICAgICB9LFxuICAgICkuc3RyaW5nVmFsdWU7XG4gICAgY29uc3QgZXhlY3V0aW9uUm9sZSA9IG5ldyBSb2xlKHRoaXMsIFwiZXhlY3V0aW9uUm9sZVwiLCB7XG4gICAgICBhc3N1bWVkQnk6IG5ldyBTZXJ2aWNlUHJpbmNpcGFsKFwiZWNzLXRhc2tzLmFtYXpvbmF3cy5jb21cIiksXG4gICAgfSk7XG4gICAgZXhlY3V0aW9uUm9sZS5hZGRNYW5hZ2VkUG9saWN5KFxuICAgICAgTWFuYWdlZFBvbGljeS5mcm9tQXdzTWFuYWdlZFBvbGljeU5hbWUoXG4gICAgICAgIFwic2VydmljZS1yb2xlL0FtYXpvbkVDU1Rhc2tFeGVjdXRpb25Sb2xlUG9saWN5XCIsXG4gICAgICApLFxuICAgICk7XG4gICAgZXhlY3V0aW9uUm9sZS5hZGRNYW5hZ2VkUG9saWN5KFxuICAgICAgTWFuYWdlZFBvbGljeS5mcm9tQXdzTWFuYWdlZFBvbGljeU5hbWUoXCJBbWF6b25TU01SZWFkT25seUFjY2Vzc1wiKSxcbiAgICApO1xuICAgIGV4ZWN1dGlvblJvbGUuYWRkTWFuYWdlZFBvbGljeShcbiAgICAgIE1hbmFnZWRQb2xpY3kuZnJvbUF3c01hbmFnZWRQb2xpY3lOYW1lKFwiQW1hem9uUkRTUmVhZE9ubHlBY2Nlc3NcIiksXG4gICAgKTtcbiAgICBleGVjdXRpb25Sb2xlLmFkZE1hbmFnZWRQb2xpY3koXG4gICAgICBNYW5hZ2VkUG9saWN5LmZyb21Bd3NNYW5hZ2VkUG9saWN5TmFtZShcbiAgICAgICAgXCJBbWF6b25FQzJDb250YWluZXJSZWdpc3RyeVJlYWRPbmx5XCIsXG4gICAgICApLFxuICAgICk7XG4gICAgY29uc3QgdXBsb2Fkc0J1Y2tldEFybiA9IGBhcm46YXdzOnMzOjo6JHt1cGxvYWRzQnVja2V0TmFtZX1gO1xuICAgIGNvbnN0IHVwbG9hZHNCdWNrZXQgPSBCdWNrZXQuZnJvbUJ1Y2tldEFybihcbiAgICAgIHRoaXMsXG4gICAgICBcInVwbG9hZHNCdWNrZXRcIixcbiAgICAgIHVwbG9hZHNCdWNrZXRBcm4sXG4gICAgKTtcbiAgICB1cGxvYWRzQnVja2V0LmdyYW50UmVhZFdyaXRlKGV4ZWN1dGlvblJvbGUpO1xuICAgIHVwbG9hZHNCdWNrZXQuZ3JhbnRQdXQoZXhlY3V0aW9uUm9sZSk7XG4gICAgY29uc3Qgc2VzSWRlbnRpdHkgPSBFbWFpbElkZW50aXR5LmZyb21FbWFpbElkZW50aXR5TmFtZShcbiAgICAgIHRoaXMsXG4gICAgICBcInNlc0lkZW50aXR5XCIsXG4gICAgICBcImhvdXNpbmdiYXlhcmVhLm9yZ1wiLFxuICAgICk7XG4gICAgc2VzSWRlbnRpdHkuZ3JhbnRTZW5kRW1haWwoZXhlY3V0aW9uUm9sZSk7XG5cbiAgICBjb25zdCBwb2xpY3kgPSBuZXcgUG9saWN5U3RhdGVtZW50KHtcbiAgICAgIGFjdGlvbnM6IFtcbiAgICAgICAgXCJzZXM6U2VuZEVtYWlsXCIsXG4gICAgICAgIFwic2VzOlNlbmRSYXdFbWFpbFwiLFxuICAgICAgICBcInNlczpTZW5kVGVtcGxhdGVkRW1haWxcIixcbiAgICAgICAgXCJzZXM6U2VuZFJhd1RlbXBsYXRlZEVtYWlsXCIsXG4gICAgICAgIFwic2VzOlNlbmRCdWxrVGVtcGxhdGVkRW1haWxcIixcbiAgICAgICAgXCJzZXM6VXNlQ29uZmlndXJhdGlvblwiLFxuICAgICAgICBcInNlczpTZW5kQnVsa0VtYWlsXCIsXG4gICAgICBdLFxuICAgICAgcmVzb3VyY2VzOiBbXG4gICAgICAgIHNlc0lkZW50aXR5LmVtYWlsSWRlbnRpdHlBcm4sXG4gICAgICAgIGBhcm46YXdzOnNlczoke3Byb3BzLmVudi5yZWdpb259OiR7cHJvcHMuZW52LmFjY291bnR9OmNvbmZpZ3VyYXRpb24tc2V0L2R3YXktY29uZmlnLXNldGAsXG4gICAgICAgIGBhcm46YXdzOnNlczoke3Byb3BzLmVudi5yZWdpb259OiR7cHJvcHMuZW52LmFjY291bnR9OmlkZW50aXR5LypgLFxuICAgICAgXSxcbiAgICB9KTtcbiAgICBleGVjdXRpb25Sb2xlLmFkZFRvUG9saWN5KHBvbGljeSk7XG5cbiAgICBjb25zdCBtaW5UYXNrcyA9IFN0cmluZ1BhcmFtZXRlci5mcm9tU3RyaW5nUGFyYW1ldGVyQXR0cmlidXRlcyhcbiAgICAgIHRoaXMsXG4gICAgICBcIm1pblRhc2tzXCIsXG4gICAgICB7XG4gICAgICAgIHBhcmFtZXRlck5hbWU6IGAvZG9vcndheS8ke3Byb3BzLmVudmlyb25tZW50fS9pbnRlcm5hbC1hcGkvbWluaW11bVRhc2tzYCxcbiAgICAgIH0sXG4gICAgKS5zdHJpbmdWYWx1ZTtcbiAgICBjb25zdCB0YXNrID0gbmV3IFRhc2tEZWZpbml0aW9uKHRoaXMsIFwidGFza1wiLCB7XG4gICAgICBjb21wYXRpYmlsaXR5OiBDb21wYXRpYmlsaXR5LkZBUkdBVEUsXG4gICAgICBjcHU6IFwiMjA0OFwiLFxuICAgICAgbWVtb3J5TWlCOiBcIjQwOTZcIixcbiAgICAgIGV4ZWN1dGlvblJvbGU6IGV4ZWN1dGlvblJvbGUsXG4gICAgICB0YXNrUm9sZTogZXhlY3V0aW9uUm9sZSxcbiAgICAgIG5ldHdvcmtNb2RlOiBOZXR3b3JrTW9kZS5BV1NfVlBDLFxuICAgIH0pO1xuICAgIHRhc2suYWRkQ29udGFpbmVyKFwiaW50ZXJuYWwtYXBpXCIsIHtcbiAgICAgIGltYWdlOiBDb250YWluZXJJbWFnZS5mcm9tUmVnaXN0cnkoXG4gICAgICAgIGAzNjQwNzYzOTE3NjMuZGtyLmVjci51cy13ZXN0LTEuYW1hem9uYXdzLmNvbS9kb29yd2F5LSR7cHJvcHMuZW52aXJvbm1lbnR9L2JhY2tlbmQ6cnVuYCxcbiAgICAgICksXG4gICAgICBjcHU6IDEsXG4gICAgICBtZW1vcnlMaW1pdE1pQjogMTAyNCxcbiAgICAgIGVzc2VudGlhbDogdHJ1ZSxcbiAgICAgIGxvZ2dpbmc6IExvZ0RyaXZlcnMuYXdzTG9ncyh7XG4gICAgICAgIHN0cmVhbVByZWZpeDogXCJpbnRlcm5hbC1hcGlcIixcbiAgICAgICAgbG9nR3JvdXA6IExvZ0dyb3VwLmZyb21Mb2dHcm91cE5hbWUoXG4gICAgICAgICAgdGhpcyxcbiAgICAgICAgICBcImxvZ0dyb3VwXCIsXG4gICAgICAgICAgYGRvb3J3YXktJHtwcm9wcy5lbnZpcm9ubWVudH0tdGFza3NgLFxuICAgICAgICApLFxuICAgICAgfSksXG4gICAgICBzZWNyZXRzOiB7XG4gICAgICAgIEFQUF9TRUNSRVQ6IFNlY3JldC5mcm9tU2VjcmV0c01hbmFnZXIoXG4gICAgICAgICAgc2VjcmV0LlNlY3JldC5mcm9tU2VjcmV0TmFtZVYyKFxuICAgICAgICAgICAgdGhpcyxcbiAgICAgICAgICAgIFwiYXBwLXNlY3JldFwiLFxuICAgICAgICAgICAgYGFwcC1zZWNyZXQtJHtwcm9wcy5lbnZpcm9ubWVudH1gLFxuICAgICAgICAgICksXG4gICAgICAgICksXG4gICAgICAgIENMT1VESU5BUllfS0VZOiBTZWNyZXQuZnJvbVNlY3JldHNNYW5hZ2VyKFxuICAgICAgICAgIHNlY3JldC5TZWNyZXQuZnJvbVNlY3JldE5hbWVWMihcbiAgICAgICAgICAgIHRoaXMsXG4gICAgICAgICAgICBcImNsb3VkaW5hcnlrZXlcIixcbiAgICAgICAgICAgIGBDTE9VRElOQVJZX0tFWWAsXG4gICAgICAgICAgKSxcbiAgICAgICAgKSxcbiAgICAgICAgR09PR0xFX0FQSV9JRDogU2VjcmV0LmZyb21TZWNyZXRzTWFuYWdlcihcbiAgICAgICAgICBzZWNyZXQuU2VjcmV0LmZyb21TZWNyZXROYW1lVjIodGhpcywgXCJnb29nbGVBcGlJZFwiLCBcIkdPT0dMRV9BUElfSURcIiksXG4gICAgICAgICksXG4gICAgICAgIEdPT0dMRV9BUElfRU1BSUw6IFNlY3JldC5mcm9tU2VjcmV0c01hbmFnZXIoXG4gICAgICAgICAgc2VjcmV0LlNlY3JldC5mcm9tU2VjcmV0TmFtZVYyKFxuICAgICAgICAgICAgdGhpcyxcbiAgICAgICAgICAgIFwiZ29vZ2xlQXBpRW1haWxcIixcbiAgICAgICAgICAgIFwiR09PR0xFX0FQSV9FTUFJTFwiLFxuICAgICAgICAgICksXG4gICAgICAgICksXG4gICAgICAgIEdPT0dMRV9BUElfS0VZOiBTZWNyZXQuZnJvbVNlY3JldHNNYW5hZ2VyKFxuICAgICAgICAgIHNlY3JldC5TZWNyZXQuZnJvbVNlY3JldE5hbWVWMihcbiAgICAgICAgICAgIHRoaXMsXG4gICAgICAgICAgICBcImdvb2dsZUFwaUtleVwiLFxuICAgICAgICAgICAgXCJHT09HTEVfQVBJX0tFWVwiLFxuICAgICAgICAgICksXG4gICAgICAgICksXG4gICAgICAgIEdPVkRFTElWRVJZX0FQSV9VUkw6IFNlY3JldC5mcm9tU2VjcmV0c01hbmFnZXIoXG4gICAgICAgICAgc2VjcmV0LlNlY3JldC5mcm9tU2VjcmV0TmFtZVYyKFxuICAgICAgICAgICAgdGhpcyxcbiAgICAgICAgICAgIFwiZ292ZGVsaXZlcnlBcGlVcmxcIixcbiAgICAgICAgICAgIFwiR09WREVMSVZFUllfQVBJX1VSTFwiLFxuICAgICAgICAgICksXG4gICAgICAgICksXG4gICAgICAgIEdPVkRFTElWRVJZX1BBU1NXT1JEOiBTZWNyZXQuZnJvbVNlY3JldHNNYW5hZ2VyKFxuICAgICAgICAgIHNlY3JldC5TZWNyZXQuZnJvbVNlY3JldE5hbWVWMihcbiAgICAgICAgICAgIHRoaXMsXG4gICAgICAgICAgICBcImdvdmRlbGl2ZXJ5UGFzc3dvcmRcIixcbiAgICAgICAgICAgIFwiR09WREVMSVZFUllfUEFTU1dPUkRcIixcbiAgICAgICAgICApLFxuICAgICAgICApLFxuICAgICAgICBHT1ZERUxJVkVSWV9VU0VSTkFNRTogU2VjcmV0LmZyb21TZWNyZXRzTWFuYWdlcihcbiAgICAgICAgICBzZWNyZXQuU2VjcmV0LmZyb21TZWNyZXROYW1lVjIoXG4gICAgICAgICAgICB0aGlzLFxuICAgICAgICAgICAgXCJnb3ZkZWxpdmVyeVVzZXJuYW1lXCIsXG4gICAgICAgICAgICBcIkdPVkRFTElWRVJZX1VTRVJOQU1FXCIsXG4gICAgICAgICAgKSxcbiAgICAgICAgKSxcbiAgICAgICAgRU1BSUxfQVBJX0tFWTogU2VjcmV0LmZyb21TZWNyZXRzTWFuYWdlcihcbiAgICAgICAgICBzZWNyZXQuU2VjcmV0LmZyb21TZWNyZXROYW1lVjIodGhpcywgXCJlbWFpbEtleVwiLCBcIkVNQUlMX0FQSV9LRVlcIiksXG4gICAgICAgICksXG4gICAgICAgIERBVEFCQVNFX1VSTDogU2VjcmV0LmZyb21TZWNyZXRzTWFuYWdlcihcbiAgICAgICAgICBzZWNyZXQuU2VjcmV0LmZyb21TZWNyZXROYW1lVjIoXG4gICAgICAgICAgICB0aGlzLFxuICAgICAgICAgICAgXCJkYlVybFwiLFxuICAgICAgICAgICAgU3RyaW5nUGFyYW1ldGVyLmZyb21TdHJpbmdQYXJhbWV0ZXJBdHRyaWJ1dGVzKFxuICAgICAgICAgICAgICB0aGlzLFxuICAgICAgICAgICAgICBcImRiU2VjcmV0TmFtZVwiLFxuICAgICAgICAgICAgICB7XG4gICAgICAgICAgICAgICAgcGFyYW1ldGVyTmFtZTogYC9kb29yd2F5LyR7cHJvcHMuZW52aXJvbm1lbnR9L2RiL3NlY3JldGAsXG4gICAgICAgICAgICAgIH0sXG4gICAgICAgICAgICApLnN0cmluZ1ZhbHVlLFxuICAgICAgICAgICksXG4gICAgICAgICAgXCJ1cmlcIixcbiAgICAgICAgKSxcbiAgICAgICAgVEhST1RUTEVfTElNSVQ6IFNlY3JldC5mcm9tU3NtUGFyYW1ldGVyKFxuICAgICAgICAgIFN0cmluZ1BhcmFtZXRlci5mcm9tU3RyaW5nUGFyYW1ldGVyQXR0cmlidXRlcyhcbiAgICAgICAgICAgIHRoaXMsXG4gICAgICAgICAgICBcIlRIUk9UVExFX0xJTUlUXCIsXG4gICAgICAgICAgICB7XG4gICAgICAgICAgICAgIHBhcmFtZXRlck5hbWU6IGAvZG9vcndheS8ke3Byb3BzLmVudmlyb25tZW50fS9pbnRlcm5hbC1hcGkvVEhST1RUTEVfTElNSVRgLFxuICAgICAgICAgICAgfSxcbiAgICAgICAgICApLFxuICAgICAgICApLFxuICAgICAgICBMT0dfTEVWRUw6IFNlY3JldC5mcm9tU3NtUGFyYW1ldGVyKFxuICAgICAgICAgIFN0cmluZ1BhcmFtZXRlci5mcm9tU3RyaW5nUGFyYW1ldGVyQXR0cmlidXRlcyh0aGlzLCBcIkxPR19MRVZFTFwiLCB7XG4gICAgICAgICAgICBwYXJhbWV0ZXJOYW1lOiBgL2Rvb3J3YXkvJHtwcm9wcy5lbnZpcm9ubWVudH0vaW50ZXJuYWwtYXBpL0xPR19MRVZFTGAsXG4gICAgICAgICAgfSksXG4gICAgICAgICksXG4gICAgICAgIC8vIExJU1RJTkdfUFJPQ0VTU0lOR19DUk9OX1NUUklORzogU2VjcmV0LmZyb21Tc21QYXJhbWV0ZXIoXG4gICAgICAgIC8vICAgU3RyaW5nUGFyYW1ldGVyLmZyb21TdHJpbmdQYXJhbWV0ZXJBdHRyaWJ1dGVzKFxuICAgICAgICAvLyAgICAgdGhpcyxcbiAgICAgICAgLy8gICAgIFwiTElTVElOR19QUk9DRVNTSU5HX0NST05fU1RSSU5HXCIsXG4gICAgICAgIC8vICAgICB7XG4gICAgICAgIC8vICAgICAgIHBhcmFtZXRlck5hbWU6IGAvZG9vcndheS8ke3Byb3BzLmVudmlyb25tZW50fS9pbnRlcm5hbC1hcGkvTElTVElOR19QUk9DRVNTSU5HX0NST05fU1RSSU5HYCxcbiAgICAgICAgLy8gICAgIH0sXG4gICAgICAgIC8vICAgKSxcbiAgICAgICAgLy8gKSxcbiAgICAgICAgLy8gTE9UVEVSWV9QUk9DRVNTSU5HX0NST05fU1RSSU5HOiBTZWNyZXQuZnJvbVNzbVBhcmFtZXRlcihcbiAgICAgICAgLy8gICBTdHJpbmdQYXJhbWV0ZXIuZnJvbVN0cmluZ1BhcmFtZXRlckF0dHJpYnV0ZXMoXG4gICAgICAgIC8vICAgICB0aGlzLFxuICAgICAgICAvLyAgICAgXCJMT1RURVJZX1BST0NFU1NJTkdfQ1JPTl9TVFJJTkdcIixcbiAgICAgICAgLy8gICAgIHtcbiAgICAgICAgLy8gICAgICAgcGFyYW1ldGVyTmFtZTogYC9kb29yd2F5LyR7cHJvcHMuZW52aXJvbm1lbnR9L2ludGVybmFsLWFwaS9MT1RURVJZX1BST0NFU1NJTkdfQ1JPTl9TVFJJTkdgLFxuICAgICAgICAvLyAgICAgfSxcbiAgICAgICAgLy8gICApLFxuICAgICAgICAvLyApLFxuICAgICAgICAvLyBMT1RURVJZX1BVQkxJU0hfUFJPQ0VTU0lOR19DUk9OX1NUUklORzogU2VjcmV0LmZyb21Tc21QYXJhbWV0ZXIoXG4gICAgICAgIC8vICAgU3RyaW5nUGFyYW1ldGVyLmZyb21TdHJpbmdQYXJhbWV0ZXJBdHRyaWJ1dGVzKFxuICAgICAgICAvLyAgICAgdGhpcyxcbiAgICAgICAgLy8gICAgIFwiTE9UVEVSWV9QVUJMSVNIX1BST0NFU1NJTkdfQ1JPTl9TVFJJTkdcIixcbiAgICAgICAgLy8gICAgIHtcbiAgICAgICAgLy8gICAgICAgcGFyYW1ldGVyTmFtZTogYC9kb29yd2F5LyR7cHJvcHMuZW52aXJvbm1lbnR9L2ludGVybmFsLWFwaS9MT1RURVJZX1BVQkxJU0hfUFJPQ0VTU0lOR19DUk9OX1NUUklOR2AsXG4gICAgICAgIC8vICAgICB9LFxuICAgICAgICAvLyAgICksXG4gICAgICAgIC8vICksXG4gICAgICAgIC8vIEFGU19QUk9DRVNTSU5HX0NST05fU1RSSU5HOiBTZWNyZXQuZnJvbVNzbVBhcmFtZXRlcihcbiAgICAgICAgLy8gICBTdHJpbmdQYXJhbWV0ZXIuZnJvbVN0cmluZ1BhcmFtZXRlckF0dHJpYnV0ZXMoXG4gICAgICAgIC8vICAgICB0aGlzLFxuICAgICAgICAvLyAgICAgXCJBRlNfUFJPQ0VTU0lOR19DUk9OX1NUUklOR1wiLFxuICAgICAgICAvLyAgICAge1xuICAgICAgICAvLyAgICAgICBwYXJhbWV0ZXJOYW1lOiBgL2Rvb3J3YXkvJHtwcm9wcy5lbnZpcm9ubWVudH0vaW50ZXJuYWwtYXBpL0FGU19QUk9DRVNTSU5HX0NST05fU1RSSU5HYCxcbiAgICAgICAgLy8gICAgIH0sXG4gICAgICAgIC8vICAgKSxcbiAgICAgICAgLy8gKSxcbiAgICAgICAgTE9UVEVSWV9EQVlTX1RJTExfRVhQSVJZOiBTZWNyZXQuZnJvbVNzbVBhcmFtZXRlcihcbiAgICAgICAgICBTdHJpbmdQYXJhbWV0ZXIuZnJvbVN0cmluZ1BhcmFtZXRlckF0dHJpYnV0ZXMoXG4gICAgICAgICAgICB0aGlzLFxuICAgICAgICAgICAgXCJMT1RURVJZX0RBWVNfVElMTF9FWFBJUllcIixcbiAgICAgICAgICAgIHtcbiAgICAgICAgICAgICAgcGFyYW1ldGVyTmFtZTogYC9kb29yd2F5LyR7cHJvcHMuZW52aXJvbm1lbnR9L2ludGVybmFsLWFwaS9MT1RURVJZX0RBWVNfVElMTF9FWFBJUllgLFxuICAgICAgICAgICAgfSxcbiAgICAgICAgICApLFxuICAgICAgICApLFxuICAgICAgICBNRkFfQ09ERV9MRU5HVEg6IFNlY3JldC5mcm9tU3NtUGFyYW1ldGVyKFxuICAgICAgICAgIFN0cmluZ1BhcmFtZXRlci5mcm9tU3RyaW5nUGFyYW1ldGVyQXR0cmlidXRlcyhcbiAgICAgICAgICAgIHRoaXMsXG4gICAgICAgICAgICBcIk1GQV9DT0RFX0xFTkdUSFwiLFxuICAgICAgICAgICAge1xuICAgICAgICAgICAgICBwYXJhbWV0ZXJOYW1lOiBgL2Rvb3J3YXkvJHtwcm9wcy5lbnZpcm9ubWVudH0vaW50ZXJuYWwtYXBpL01GQV9DT0RFX0xFTkdUSGAsXG4gICAgICAgICAgICB9LFxuICAgICAgICAgICksXG4gICAgICAgICksXG4gICAgICAgIE1GQV9DT0RFX1ZBTElEOiBTZWNyZXQuZnJvbVNzbVBhcmFtZXRlcihcbiAgICAgICAgICBTdHJpbmdQYXJhbWV0ZXIuZnJvbVN0cmluZ1BhcmFtZXRlckF0dHJpYnV0ZXMoXG4gICAgICAgICAgICB0aGlzLFxuICAgICAgICAgICAgXCJNRkFfQ09ERV9WQUxJRFwiLFxuICAgICAgICAgICAge1xuICAgICAgICAgICAgICBwYXJhbWV0ZXJOYW1lOiBgL2Rvb3J3YXkvJHtwcm9wcy5lbnZpcm9ubWVudH0vaW50ZXJuYWwtYXBpL01GQV9DT0RFX1ZBTElEYCxcbiAgICAgICAgICAgIH0sXG4gICAgICAgICAgKSxcbiAgICAgICAgKSxcblxuICAgICAgICBHT1ZERUxJVkVSWV9UT1BJQzogU2VjcmV0LmZyb21Tc21QYXJhbWV0ZXIoXG4gICAgICAgICAgU3RyaW5nUGFyYW1ldGVyLmZyb21TdHJpbmdQYXJhbWV0ZXJBdHRyaWJ1dGVzKFxuICAgICAgICAgICAgdGhpcyxcbiAgICAgICAgICAgIFwiR09WREVMSVZFUllfVE9QSUNcIixcbiAgICAgICAgICAgIHtcbiAgICAgICAgICAgICAgcGFyYW1ldGVyTmFtZTogYC9kb29yd2F5LyR7cHJvcHMuZW52aXJvbm1lbnR9L2ludGVybmFsLWFwaS9HT1ZERUxJVkVSWV9UT1BJQ2AsXG4gICAgICAgICAgICB9LFxuICAgICAgICAgICksXG4gICAgICAgICksXG4gICAgICAgIFRFTVBfRklMRV9DTEVBUl9DUk9OX1NUUklORzogU2VjcmV0LmZyb21Tc21QYXJhbWV0ZXIoXG4gICAgICAgICAgU3RyaW5nUGFyYW1ldGVyLmZyb21TdHJpbmdQYXJhbWV0ZXJBdHRyaWJ1dGVzKFxuICAgICAgICAgICAgdGhpcyxcbiAgICAgICAgICAgIFwiVEVNUF9GSUxFX0NMRUFSX0NST05fU1RSSU5HXCIsXG4gICAgICAgICAgICB7XG4gICAgICAgICAgICAgIHBhcmFtZXRlck5hbWU6IGAvZG9vcndheS8ke3Byb3BzLmVudmlyb25tZW50fS9pbnRlcm5hbC1hcGkvVEVNUF9GSUxFX0NMRUFSX0NST05fU1RSSU5HYCxcbiAgICAgICAgICAgIH0sXG4gICAgICAgICAgKSxcbiAgICAgICAgKSxcbiAgICAgICAgUEFSVE5FUlNfUE9SVEFMX1VSTDogU2VjcmV0LmZyb21Tc21QYXJhbWV0ZXIoXG4gICAgICAgICAgU3RyaW5nUGFyYW1ldGVyLmZyb21TdHJpbmdQYXJhbWV0ZXJBdHRyaWJ1dGVzKFxuICAgICAgICAgICAgdGhpcyxcbiAgICAgICAgICAgIFwiUEFSVE5FUlNfUE9SVEFMX1VSTFwiLFxuICAgICAgICAgICAge1xuICAgICAgICAgICAgICBwYXJhbWV0ZXJOYW1lOiBgL2Rvb3J3YXkvJHtwcm9wcy5lbnZpcm9ubWVudH0vaW50ZXJuYWwtYXBpL1BBUlRORVJTX1BPUlRBTF9VUkxgLFxuICAgICAgICAgICAgfSxcbiAgICAgICAgICApLFxuICAgICAgICApLFxuICAgICAgICBQQVJUTkVSU19CQVNFX1VSTDogU2VjcmV0LmZyb21Tc21QYXJhbWV0ZXIoXG4gICAgICAgICAgU3RyaW5nUGFyYW1ldGVyLmZyb21TdHJpbmdQYXJhbWV0ZXJBdHRyaWJ1dGVzKFxuICAgICAgICAgICAgdGhpcyxcbiAgICAgICAgICAgIFwiUEFSVE5FUlNfUE9SVEFMX0JBU0VfVVJMXCIsXG4gICAgICAgICAgICB7XG4gICAgICAgICAgICAgIHBhcmFtZXRlck5hbWU6IGAvZG9vcndheS8ke3Byb3BzLmVudmlyb25tZW50fS9pbnRlcm5hbC1hcGkvUEFSVE5FUlNfQkFTRV9VUkxgLFxuICAgICAgICAgICAgfSxcbiAgICAgICAgICApLFxuICAgICAgICApLFxuICAgICAgICBUSFJPVFRMRV9UVEw6IFNlY3JldC5mcm9tU3NtUGFyYW1ldGVyKFxuICAgICAgICAgIFN0cmluZ1BhcmFtZXRlci5mcm9tU3RyaW5nUGFyYW1ldGVyQXR0cmlidXRlcyh0aGlzLCBcIlRIUk9UVExFX1RUTFwiLCB7XG4gICAgICAgICAgICBwYXJhbWV0ZXJOYW1lOiBgL2Rvb3J3YXkvJHtwcm9wcy5lbnZpcm9ubWVudH0vaW50ZXJuYWwtYXBpL1RIUk9UVExFX1RUTGAsXG4gICAgICAgICAgfSksXG4gICAgICAgICksXG4gICAgICAgIEFTU0VUX0ZTX0NPTkZJR19zM19SRUdJT046IFNlY3JldC5mcm9tU3NtUGFyYW1ldGVyKFxuICAgICAgICAgIFN0cmluZ1BhcmFtZXRlci5mcm9tU3RyaW5nUGFyYW1ldGVyQXR0cmlidXRlcyhcbiAgICAgICAgICAgIHRoaXMsXG4gICAgICAgICAgICBcIkFTU0VUX0ZTX0NPTkZJR19zM19SRUdJT05cIixcbiAgICAgICAgICAgIHtcbiAgICAgICAgICAgICAgcGFyYW1ldGVyTmFtZTogYC9kb29yd2F5LyR7cHJvcHMuZW52aXJvbm1lbnR9L2ludGVybmFsLWFwaS9BU1NFVF9GU19DT05GSUdfczNfUkVHSU9OYCxcbiAgICAgICAgICAgIH0sXG4gICAgICAgICAgKSxcbiAgICAgICAgKSxcbiAgICAgICAgQVNTRVRfRlNfQ09ORklHX3MzX1VSTF9GT1JNQVQ6IFNlY3JldC5mcm9tU3NtUGFyYW1ldGVyKFxuICAgICAgICAgIFN0cmluZ1BhcmFtZXRlci5mcm9tU3RyaW5nUGFyYW1ldGVyQXR0cmlidXRlcyhcbiAgICAgICAgICAgIHRoaXMsXG4gICAgICAgICAgICBcIkFTU0VUX0ZTX0NPTkZJR19zM19VUkxfRk9STUFUXCIsXG4gICAgICAgICAgICB7XG4gICAgICAgICAgICAgIHBhcmFtZXRlck5hbWU6IGAvZG9vcndheS8ke3Byb3BzLmVudmlyb25tZW50fS9pbnRlcm5hbC1hcGkvQVNTRVRfRlNfQ09ORklHX3MzX1VSTF9GT1JNQVRgLFxuICAgICAgICAgICAgfSxcbiAgICAgICAgICApLFxuICAgICAgICApLFxuICAgICAgICBBU1NFVF9VUExPQURfTUFYX1NJWkU6IFNlY3JldC5mcm9tU3NtUGFyYW1ldGVyKFxuICAgICAgICAgIFN0cmluZ1BhcmFtZXRlci5mcm9tU3RyaW5nUGFyYW1ldGVyQXR0cmlidXRlcyhcbiAgICAgICAgICAgIHRoaXMsXG4gICAgICAgICAgICBcIkFTU0VUX1VQTE9BRF9NQVhfU0laRVwiLFxuICAgICAgICAgICAge1xuICAgICAgICAgICAgICBwYXJhbWV0ZXJOYW1lOiBgL2Rvb3J3YXkvJHtwcm9wcy5lbnZpcm9ubWVudH0vaW50ZXJuYWwtYXBpL0FTU0VUX1VQTE9BRF9NQVhfU0laRWAsXG4gICAgICAgICAgICB9LFxuICAgICAgICAgICksXG4gICAgICAgICksXG4gICAgICAgIEFVVEhfTE9DS19MT0dJTl9DT09MRE9XTjogU2VjcmV0LmZyb21Tc21QYXJhbWV0ZXIoXG4gICAgICAgICAgU3RyaW5nUGFyYW1ldGVyLmZyb21TdHJpbmdQYXJhbWV0ZXJBdHRyaWJ1dGVzKFxuICAgICAgICAgICAgdGhpcyxcbiAgICAgICAgICAgIFwiQVVUSF9MT0NLX0xPR0lOX0NPT0xET1dOXCIsXG4gICAgICAgICAgICB7XG4gICAgICAgICAgICAgIHBhcmFtZXRlck5hbWU6IGAvZG9vcndheS8ke3Byb3BzLmVudmlyb25tZW50fS9pbnRlcm5hbC1hcGkvQVVUSF9MT0NLX0xPR0lOX0NPT0xET1dOYCxcbiAgICAgICAgICAgIH0sXG4gICAgICAgICAgKSxcbiAgICAgICAgKSxcbiAgICAgICAgQVVUSF9MT0NLX0xPR0lOX0FGVEVSX0ZBSUxFRF9BVFRFTVBUUzogU2VjcmV0LmZyb21Tc21QYXJhbWV0ZXIoXG4gICAgICAgICAgU3RyaW5nUGFyYW1ldGVyLmZyb21TdHJpbmdQYXJhbWV0ZXJBdHRyaWJ1dGVzKFxuICAgICAgICAgICAgdGhpcyxcbiAgICAgICAgICAgIFwiQVVUSF9MT0NLX0xPR0lOX0FGVEVSX0ZBSUxFRF9BVFRFTVBUU1wiLFxuICAgICAgICAgICAge1xuICAgICAgICAgICAgICBwYXJhbWV0ZXJOYW1lOiBgL2Rvb3J3YXkvJHtwcm9wcy5lbnZpcm9ubWVudH0vaW50ZXJuYWwtYXBpL0FVVEhfTE9DS19MT0dJTl9BRlRFUl9GQUlMRURfQVRURU1QVFNgLFxuICAgICAgICAgICAgfSxcbiAgICAgICAgICApLFxuICAgICAgICApLFxuICAgICAgICBDT1JTX09SSUdJTlM6IFNlY3JldC5mcm9tU3NtUGFyYW1ldGVyKFxuICAgICAgICAgIFN0cmluZ1BhcmFtZXRlci5mcm9tU3RyaW5nUGFyYW1ldGVyQXR0cmlidXRlcyh0aGlzLCBcIkNPUlNfT1JJR0lOU1wiLCB7XG4gICAgICAgICAgICBwYXJhbWV0ZXJOYW1lOiBgL2Rvb3J3YXkvJHtwcm9wcy5lbnZpcm9ubWVudH0vaW50ZXJuYWwtYXBpL0NPUlNfT1JJR0lOU2AsXG4gICAgICAgICAgfSksXG4gICAgICAgICksXG4gICAgICAgIEFTU0VUX0ZTX0NPTkZJR19zM19CVUNLRVQ6IFNlY3JldC5mcm9tU3NtUGFyYW1ldGVyKFxuICAgICAgICAgIFN0cmluZ1BhcmFtZXRlci5mcm9tU3RyaW5nUGFyYW1ldGVyQXR0cmlidXRlcyhcbiAgICAgICAgICAgIHRoaXMsXG4gICAgICAgICAgICBcIkFTU0VUX0ZTX0NPTkZJR19zM19CVUNLRVRcIixcbiAgICAgICAgICAgIHtcbiAgICAgICAgICAgICAgcGFyYW1ldGVyTmFtZTogYC9kb29yd2F5LyR7cHJvcHMuZW52aXJvbm1lbnR9L3MzL3VwbG9hZHNCdWNrZXROYW1lYCxcbiAgICAgICAgICAgIH0sXG4gICAgICAgICAgKSxcbiAgICAgICAgKSxcbiAgICAgICAgRFVQTElDQVRFU19DTE9TRV9EQVRFOiBTZWNyZXQuZnJvbVNzbVBhcmFtZXRlcihcbiAgICAgICAgICBTdHJpbmdQYXJhbWV0ZXIuZnJvbVN0cmluZ1BhcmFtZXRlckF0dHJpYnV0ZXMoXG4gICAgICAgICAgICB0aGlzLFxuICAgICAgICAgICAgXCJEVVBMSUNBVEVTX0NMT1NFX0RBVEVcIixcbiAgICAgICAgICAgIHtcbiAgICAgICAgICAgICAgcGFyYW1ldGVyTmFtZTogYC9kb29yd2F5LyR7cHJvcHMuZW52aXJvbm1lbnR9L2ludGVybmFsLWFwaS9EVVBMSUNBVEVTX0NMT1NFX0RBVEVgLFxuICAgICAgICAgICAgfSxcbiAgICAgICAgICApLFxuICAgICAgICApLFxuICAgICAgICBEVVBMSUNBVEVTX1BST0NFU1NJTkdfQ1JPTl9TVFJJTkc6IFNlY3JldC5mcm9tU3NtUGFyYW1ldGVyKFxuICAgICAgICAgIFN0cmluZ1BhcmFtZXRlci5mcm9tU3RyaW5nUGFyYW1ldGVyQXR0cmlidXRlcyhcbiAgICAgICAgICAgIHRoaXMsXG4gICAgICAgICAgICBcIkRVUExJQ0FURVNfUFJPQ0VTU0lOR19DUk9OX1NUUklOR1wiLFxuICAgICAgICAgICAge1xuICAgICAgICAgICAgICBwYXJhbWV0ZXJOYW1lOiBgL2Rvb3J3YXkvJHtwcm9wcy5lbnZpcm9ubWVudH0vaW50ZXJuYWwtYXBpL0RVUExJQ0FURVNfUFJPQ0VTU0lOR19DUk9OX1NUUklOR2AsXG4gICAgICAgICAgICB9LFxuICAgICAgICAgICksXG4gICAgICAgICksXG4gICAgICAgIEhUVFBTX09GRjogU2VjcmV0LmZyb21Tc21QYXJhbWV0ZXIoXG4gICAgICAgICAgU3RyaW5nUGFyYW1ldGVyLmZyb21TdHJpbmdQYXJhbWV0ZXJBdHRyaWJ1dGVzKHRoaXMsIFwiSFRUUFNfT0ZGXCIsIHtcbiAgICAgICAgICAgIHBhcmFtZXRlck5hbWU6IGAvZG9vcndheS8ke3Byb3BzLmVudmlyb25tZW50fS9pbnRlcm5hbC1hcGkvSFRUUFNfT0ZGYCxcbiAgICAgICAgICB9KSxcbiAgICAgICAgKSxcbiAgICAgICAgU0FNRV9TSVRFOiBTZWNyZXQuZnJvbVNzbVBhcmFtZXRlcihcbiAgICAgICAgICBTdHJpbmdQYXJhbWV0ZXIuZnJvbVN0cmluZ1BhcmFtZXRlckF0dHJpYnV0ZXModGhpcywgXCJTQU1FX1NJVEVcIiwge1xuICAgICAgICAgICAgcGFyYW1ldGVyTmFtZTogYC9kb29yd2F5LyR7cHJvcHMuZW52aXJvbm1lbnR9L2ludGVybmFsLWFwaS9TQU1FX1NJVEVgLFxuICAgICAgICAgIH0pLFxuICAgICAgICApLFxuICAgICAgfSxcbiAgICAgIGVudmlyb25tZW50OiB7XG4gICAgICAgIEFTU0VUX0ZJTEVfU0VSVklDRTogXCJzM1wiLFxuICAgICAgICBMSVNUSU5HU19QUk9DRVNTSU5HX1FVRVJZOiBcIi9saXN0aW5nc1wiLFxuICAgICAgICBQT1JUOiBcIjMxMDBcIixcbiAgICAgICAgU0hPV19MTV9MSU5LUzogXCJUUlVFXCIsXG4gICAgICAgIFRJTUVfWk9ORTogXCJBbWVyaWNhL0xvc19BbmdlbGVzXCIsXG4gICAgICAgIFNIT1dfRFVQTElDQVRFUzogXCJGQUxTRVwiLFxuICAgICAgICBOT19DT0xPUjogXCJUUlVFXCIsXG4gICAgICAgIEFTU0VUX0ZTX0NPTkZJR19zM19QQVRIX1BSRUZJWDogXCJcIixcbiAgICAgIH0sXG4gICAgICBlbnRyeVBvaW50OiBbXSxcbiAgICAgIHBvcnRNYXBwaW5nczogW1xuICAgICAgICB7XG4gICAgICAgICAgY29udGFpbmVyUG9ydDogMzEwMCxcbiAgICAgICAgICBwcm90b2NvbDogUHJvdG9jb2wuVENQLFxuICAgICAgICAgIGhvc3RQb3J0OiAzMTAwLFxuICAgICAgICB9LFxuICAgICAgXSxcbiAgICB9KTtcbiAgICBjb25zdCBzZXJ2aWNlID0gbmV3IEZhcmdhdGVTZXJ2aWNlKFxuICAgICAgdGhpcyxcbiAgICAgIGBkb29yd2F5LSR7cHJvcHMuZW52aXJvbm1lbnR9LWludGVybmFsLWFwaWAsXG4gICAgICB7XG4gICAgICAgIHRhc2tEZWZpbml0aW9uOiB0YXNrLFxuICAgICAgICBzZXJ2aWNlTmFtZTogYGRvb3J3YXktJHtwcm9wcy5lbnZpcm9ubWVudH0taW50ZXJuYWwtYXBpYCxcbiAgICAgICAgY2x1c3RlcjogQ2x1c3Rlci5mcm9tQ2x1c3RlckF0dHJpYnV0ZXModGhpcywgXCJkZWZhdWx0LWNsdXN0ZXJcIiwge1xuICAgICAgICAgIGNsdXN0ZXJOYW1lOiBgZG9vcndheS0ke3Byb3BzLmVudmlyb25tZW50fS1kZWZhdWx0YCxcbiAgICAgICAgICB2cGM6IHZwYyxcbiAgICAgICAgfSksXG4gICAgICAgIHZwY1N1Ym5ldHM6IHtcbiAgICAgICAgICBzdWJuZXRzOiBhcHBTdWJuZXRzLFxuICAgICAgICB9LFxuICAgICAgICBkZXNpcmVkQ291bnQ6IDIsXG4gICAgICB9LFxuICAgICk7XG4gICAgY29uc3QgdGcgPSBuZXcgZWxiLkFwcGxpY2F0aW9uVGFyZ2V0R3JvdXAodGhpcywgXCJ0Z1wiLCB7XG4gICAgICB2cGM6IHZwYyxcbiAgICAgIHBvcnQ6IDMxMDAsXG4gICAgICBwcm90b2NvbDogZWxiLkFwcGxpY2F0aW9uUHJvdG9jb2wuSFRUUCxcbiAgICAgIHRhcmdldFR5cGU6IGVsYi5UYXJnZXRUeXBlLklQLFxuICAgICAgaGVhbHRoQ2hlY2s6IHtcbiAgICAgICAgcGF0aDogXCIvXCIsXG4gICAgICAgIHByb3RvY29sOiBlbGIuUHJvdG9jb2wuSFRUUCxcbiAgICAgICAgdGltZW91dDogY2RrLkR1cmF0aW9uLnNlY29uZHMoNSksXG4gICAgICAgIGludGVydmFsOiBjZGsuRHVyYXRpb24uc2Vjb25kcygzMCksXG4gICAgICAgIGhlYWx0aHlUaHJlc2hvbGRDb3VudDogNSxcbiAgICAgICAgdW5oZWFsdGh5VGhyZXNob2xkQ291bnQ6IDIsXG4gICAgICB9LFxuICAgIH0pO1xuICAgIHNlcnZpY2UuYXR0YWNoVG9BcHBsaWNhdGlvblRhcmdldEdyb3VwKHRnKTtcbiAgICBjb25zdCBzY2FsaW5nID0gc2VydmljZS5hdXRvU2NhbGVUYXNrQ291bnQoe1xuICAgICAgbWluQ2FwYWNpdHk6IDIsXG4gICAgICBtYXhDYXBhY2l0eTogMTAsXG4gICAgfSk7XG4gICAgc2NhbGluZy5zY2FsZU9uQ3B1VXRpbGl6YXRpb24oXCJDcHVTY2FsaW5nXCIsIHtcbiAgICAgIHRhcmdldFV0aWxpemF0aW9uUGVyY2VudDogODAsXG4gICAgICBzY2FsZUluQ29vbGRvd246IGNkay5EdXJhdGlvbi5zZWNvbmRzKDYwKSxcbiAgICAgIHNjYWxlT3V0Q29vbGRvd246IGNkay5EdXJhdGlvbi5zZWNvbmRzKDYwKSxcbiAgICB9KTtcbiAgICBjb25zdCBsaXN0ZW5lciA9IHByaXZhdGVMQi5hZGRMaXN0ZW5lcihcInByaXZhdGVMYkxpc3RlbmVyXCIsIHtcbiAgICAgIHBvcnQ6IDgwLFxuICAgICAgcHJvdG9jb2w6IGVsYi5BcHBsaWNhdGlvblByb3RvY29sLkhUVFAsXG4gICAgfSk7XG4gICAgbGlzdGVuZXIuYWRkVGFyZ2V0R3JvdXBzKFwicHJpdmF0ZUxCVEdcIiwge1xuICAgICAgdGFyZ2V0R3JvdXBzOiBbdGddLFxuICAgIH0pO1xuICAgIG5ldyBBUmVjb3JkKHRoaXMsIFwiaW50ZXJuYWxBbGlhc1wiLCB7XG4gICAgICB6b25lOiBob3N0ZWRab25lLFxuICAgICAgcmVjb3JkTmFtZTogYGJhY2tlbmQuJHtwcm9wcy5lbnZpcm9ubWVudH1gLFxuICAgICAgdGFyZ2V0OiBSZWNvcmRUYXJnZXQuZnJvbUFsaWFzKG5ldyBMb2FkQmFsYW5jZXJUYXJnZXQocHJpdmF0ZUxCKSksXG4gICAgfSk7XG4gIH1cbn1cbiJdfQ==