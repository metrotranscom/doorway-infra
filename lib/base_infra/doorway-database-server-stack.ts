import { CfnOutput, Duration, Fn, Stack } from "aws-cdk-lib";
import {
  InstanceClass,
  InstanceSize,
  InstanceType,
  Port,
  SecurityGroup,
  Vpc,
} from "aws-cdk-lib/aws-ec2";
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

import { DoorwayStackProps } from "./doorway-stack-props";

/** @class
 * This is the CDK Stack that creates an RDS Postgres database server
 */

export class DoorwayDatabaseServerStack extends Stack {
  /**
   * @constructor
   * @param Construct scope - the CDK Execution Context this is running in
   * @param string id - unique name for the stack
   * @param DoorwayStackProps props - in addition to the properties inherited by the CDK StackProps class, adds a string property of "environment" which is the name of the Doorway environment.
   */
  constructor(scope: Construct, id: string, props: DoorwayStackProps) {
    super(scope, id, props);
    // Get the network information for the VPC that this database will reside in
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
    // Create the RDS Subnet group
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
    // The database security group which takes inbound traffic over port 5432 (the postgres default port)
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
    //Create thes server itself
    const dbinstance = new DatabaseInstance(
      this,
      `doorway-database-${props.environment}`,
      {
        instanceIdentifier: `doorway-database-${props.environment}`,
        instanceType: props.environment.includes("dev")
          ? InstanceType.of(InstanceClass.T3, InstanceSize.MICRO)
          : InstanceType.of(InstanceClass.T4G, InstanceSize.SMALL),

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
    // Set up secret rotation for the database password and user
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
    // Create a stack output of the db secret arn.
    new CfnOutput(this, "dbSecret", {
      exportName: `doorwayDBSecret-${props.environment}`,
      value: dbinstance.secret!.secretArn,
    });
  }
}
