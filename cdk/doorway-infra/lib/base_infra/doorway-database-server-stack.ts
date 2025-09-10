import { CfnOutput, Duration, Fn, Stack } from "aws-cdk-lib";
import { Port, SecurityGroup, Vpc } from "aws-cdk-lib/aws-ec2";
import {
  DatabaseInstance,
  DatabaseInstanceEngine,
  StorageType,
  SubnetGroup,
} from "aws-cdk-lib/aws-rds";
import {
  SecretRotation,
  SecretRotationApplication,
} from "aws-cdk-lib/aws-secretsmanager";
import { Construct } from "constructs";
import { DoorwayStackProps } from "../service_infra/doorway_api_service-stack";

export class DoorwayDatabaseServerStack extends Stack {
  constructor(scope: Construct, id: string, props: DoorwayStackProps) {
    super(scope, id, props);
    const vpcId = Fn.importValue(`doorway-vpc-id-${props.environment}`);
    const appSGId = Fn.importValue(`doorway-app-sg-${props.environment}`);

    const vpc = Vpc.fromVpcAttributes(this, "vpc", {
      vpcId: vpcId,
      availabilityZones: ["us-west-2a", "us-west-2b"],
      privateSubnetIds: [
        Fn.importValue(`doorway-db-subnet-1-${props.environment}`),
        Fn.importValue(`doorway-db-subnet-2-${props.environment}`),
      ],
    });

    const subnetGroup = new SubnetGroup(
      this,
      `db-subnets-${props.environment}`,
      {
        description: `Database Subnet group for the doorway ${props.environment} environment`,
        vpc: vpc,
        subnetGroupName: `doorway-database-subnets-${props.environment}`,
        vpcSubnets: {
          subnets: vpc.privateSubnets,
        },
      },
    );

    const dbSG = new SecurityGroup(this, `doorway-db-sg-${props.environment}`, {
      vpc: vpc,
      securityGroupName: `doorway-db-sg-${props.environment}`,
      description: `Database security group for the doorway ${props.environment} environment`,
      allowAllOutbound: true,
    });

    dbSG.addIngressRule(
      SecurityGroup.fromSecurityGroupId(this, "appSG", appSGId),
      Port.tcp(5432),
      "Allow app access to database",
    );

    const dbinstance = new DatabaseInstance(
      this,
      `doorway-database-${props.environment}`,
      {
        instanceIdentifier: `doorway-database-${props.environment}`,
        engine: DatabaseInstanceEngine.POSTGRES,
        vpc: vpc,
        subnetGroup: subnetGroup,
        securityGroups: [dbSG],
        multiAz: false,
        deletionProtection: false,
        storageEncrypted: true,
        allocatedStorage: 20,
        storageType: StorageType.STANDARD,
        databaseName: "bloom",
        credentials: {
          username: "doorway",
        },
      },
    );
    new SecretRotation(
      this,
      `doorway-db-server-secret-rotation-${props.environment}`,
      {
        application: SecretRotationApplication.POSTGRES_ROTATION_SINGLE_USER,
        secret: dbinstance.secret!,
        target: dbinstance,
        vpc: vpc,
        automaticallyAfter: Duration.days(30),
      },
    );
    new CfnOutput(this, "dbSecret", {
      exportName: `doorwayDBSecret-${props.environment}`,
      value: dbinstance.secret!.secretArn,
    });
  }
}
