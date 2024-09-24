import * as cdk from "aws-cdk-lib";
import * as ecs from "aws-cdk-lib/aws-ecs";
import * as rds from "aws-cdk-lib/aws-rds";
import * as s3 from "aws-cdk-lib/aws-s3";
import { StringListParameter, StringParameter } from "aws-cdk-lib/aws-ssm";
export interface DoorwayAppInfraStackProps extends cdk.StackProps {
  environment: string;
}
export class DoorwayAppInfraStack extends cdk.Stack {
  public constructor(
    scope: cdk.App,
    id: string,
    props: DoorwayAppInfraStackProps,
  ) {
    super(scope, id, props);
    const dbSubnets = StringListParameter.fromListParameterAttributes(
      this,
      "dbSubnets",
      {
        parameterName: `/doorway/${props.environment}/vpc/dbSubnets`,
      },
    ).stringListValue;
    const rdsInstanceName = StringParameter.fromStringParameterAttributes(
      this,
      "rdsInstanceName",
      {
        parameterName: `/doorway/${props.environment}/rds/instanceName`,
      },
    ).stringValue;
    const rdsSubnetGroupName = StringParameter.fromStringParameterAttributes(
      this,
      "rdsSubnetGroupName",
      {
        parameterName: `/doorway/${props.environment}/rds/subnetGroupName`,
      },
    ).stringValue;
    const uploadsBucketName = StringParameter.fromStringParameterAttributes(
      this,
      "uploadsBucketName",
      {
        parameterName: `/doorway/${props.environment}/s3/uploadsBucketName`,
      },
    ).stringValue;
    // Resources
    const ecsCluster = new ecs.CfnCluster(
      this,
      `doorway-${props.environment}-default`,
      {
        capacityProviders: [],
        clusterName: `doorway-${props.environment}-default`,
        clusterSettings: [
          {
            value: "disabled",
            name: "containerInsights",
          },
        ],
        defaultCapacityProviderStrategy: [],
        tags: [
          {
            value: "Doorway Housing Project",
            key: "Project",
          },
          {
            value: "doorway-fellowship-eng-team@google.com",
            key: "Owner",
          },
          {
            value: `arn:aws:ecs:us-west-1:364076391763:cluster/doorway-${props.environment}-default`,
            key: "AWS.SSM.AppManager.ECS.Cluster.ARN",
          },
          {
            value: "doorway",
            key: "ProjectID",
          },
          {
            value: props.environment,
            key: "Environment",
          },
          {
            value: "Bloom Housing Instance",
            key: "Application",
          },
          {
            value: props.environment,
            key: "Workspace",
          },
        ],
      },
    );
    ecsCluster.cfnOptions.deletionPolicy = cdk.CfnDeletionPolicy.RETAIN;
    const rdsSubnetGroup = new rds.CfnDBSubnetGroup(
      this,
      `doorway-${props.environment}-rds-subnet-group`,
      {
        dbSubnetGroupName: rdsSubnetGroupName,
        subnetIds: dbSubnets,
        dbSubnetGroupDescription: "Managed by Terraform",
        tags: [
          {
            value: "Doorway Housing Project",
            key: "Project",
          },
          {
            value: "doorway-fellowship-eng-team@google.com",
            key: "Owner",
          },
          {
            value: "doorway",
            key: "ProjectID",
          },
          {
            value: props.environment,
            key: "Environment",
          },
          {
            value: "Bloom Housing Instance",
            key: "Application",
          },
          {
            value: props.environment,
            key: "Workspace",
          },
        ],
      },
    );
    rdsSubnetGroup.cfnOptions.deletionPolicy = cdk.CfnDeletionPolicy.RETAIN;
    const uploadsBucket = new s3.CfnBucket(
      this,
      `doorway-${props.environment}-public-uploads`,
      {
        publicAccessBlockConfiguration: {
          restrictPublicBuckets: false,
          ignorePublicAcls: false,
          blockPublicPolicy: false,
          blockPublicAcls: false,
        },
        bucketName: uploadsBucketName,
        corsConfiguration: {
          corsRules: [
            {
              allowedHeaders: ["*"],
              allowedMethods: ["GET"],
              allowedOrigins: ["https://housingbayarea.mtc.ca.gov"],
            },
          ],
        },
        ownershipControls: {
          rules: [
            {
              objectOwnership: "BucketOwnerEnforced",
            },
          ],
        },
        bucketEncryption: {
          serverSideEncryptionConfiguration: [
            {
              bucketKeyEnabled: false,
              serverSideEncryptionByDefault: {
                sseAlgorithm: "AES256",
              },
            },
          ],
        },
        tags: [
          {
            value: "doorway",
            key: "ProjectID",
          },
          {
            value: "Doorway Housing Project",
            key: "Project",
          },
          {
            value: props.environment,
            key: "Environment",
          },
          {
            value: "doorway-fellowship-eng-team@google.com",
            key: "Owner",
          },
          {
            value: "Bloom Housing Instance",
            key: "Application",
          },
          {
            value: props.environment,
            key: "Workspace",
          },
        ],
      },
    );
    uploadsBucket.cfnOptions.deletionPolicy = cdk.CfnDeletionPolicy.RETAIN;
    const rdsInstance = new rds.CfnDBInstance(
      this,
      `doorway-${this.environment}-db`,
      {
        storageEncrypted: false,
        associatedRoles: [],
        certificateDetails: {},
        processorFeatures: [],
        storageThroughput: 125,
        preferredBackupWindow: "00:00-01:00",
        monitoringInterval: 0,
        dbParameterGroupName: "default.postgres13",
        endpoint: {},
        networkType: "IPV4",
        dedicatedLogVolume: false,
        copyTagsToSnapshot: true,
        multiAz: false,
        engine: "postgres",
        tags: [
          {
            value: "doorway",
            key: "ProjectID",
          },
          {
            value: "Doorway Housing Project",
            key: "Project",
          },
          {
            value: props.environment,
            key: "Environment",
          },
          {
            value: "doorway-fellowship-eng-team@google.com",
            key: "Owner",
          },
          {
            value: "Bloom Housing Instance",
            key: "Application",
          },
          {
            value: props.environment,
            key: "Workspace",
          },
        ],
        licenseModel: "postgresql-license",
        engineVersion: "13.15",
        storageType: "gp3",
        dbInstanceClass: "db.t4g.small",
        availabilityZone: "us-west-1a",
        optionGroupName: "default:postgres-13",
        preferredMaintenanceWindow: "mon:06:38-mon:07:08",
        enablePerformanceInsights: false,
        autoMinorVersionUpgrade: true,
        dbSubnetGroupName: rdsSubnetGroup.ref,
        deletionProtection: true,
        iops: 3000,
        dbInstanceIdentifier: rdsInstanceName,
        allocatedStorage: "20",
        caCertificateIdentifier: "rds-ca-rsa2048-g1",
        manageMasterUserPassword: false,
        masterUserSecret: {},
        vpcSecurityGroups: ["sg-01e58067e38d428c3"],
        dbSecurityGroups: [],
        masterUsername: "doorway",
        dbName: "bloom",
        enableIamDatabaseAuthentication: true,
        maxAllocatedStorage: 50,
        backupRetentionPeriod: 30,
        publiclyAccessible: false,
        enableCloudwatchLogsExports: ["postgresql", "upgrade"],
      },
    );
    rdsInstance.cfnOptions.deletionPolicy = cdk.CfnDeletionPolicy.RETAIN;
  }
}
