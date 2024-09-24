import * as cdk from "aws-cdk-lib";
import * as ec2 from "aws-cdk-lib/aws-ec2";
export interface DoorwayNetworkStackProps extends cdk.StackProps {
  environment: string;
}
export class DoorwayNetworkStack extends cdk.Stack {
  public constructor(
    scope: cdk.App,
    id: string,
    props: DoorwayNetworkStackProps = { environment: "dev" },
  ) {
    super(scope, id, props);
    // Resources
    const ec2vpc00vpc0d30a8e41d677bf7900mlzDm = new ec2.CfnVPC(
      this,
      "EC2VPC00vpc0d30a8e41d677bf7900mlzDm",
      {
        cidrBlock: "10.2.0.0/16",
        enableDnsSupport: true,
        instanceTenancy: "default",
        enableDnsHostnames: true,
        tags: [
          {
            value: "Doorway Housing Project",
            key: "Project",
          },
          {
            value: "doorway",
            key: "ProjectID",
          },
          {
            value: "doorway-fellowship-eng-team@google.com",
            key: "Owner",
          },
          {
            value: `doorway-${props.environment}:default`,
            key: "Name",
          },
          {
            value: "Bloom Housing Instance",
            key: "Application",
          },
          {
            value: props.environment,
            key: "Environment",
          },
          {
            value: props.environment,
            key: "Workspace",
          },
        ],
      },
    );
    ec2vpc00vpc0d30a8e41d677bf7900mlzDm.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2NetworkAcl00acl033ab3098fb48a0d0002Wbv2 = new ec2.CfnNetworkAcl(
      this,
      "EC2NetworkAcl00acl033ab3098fb48a0d0002Wbv2",
      {
        vpcId: ec2vpc00vpc0d30a8e41d677bf7900mlzDm.ref,
        tags: [],
      },
    );
    ec2NetworkAcl00acl033ab3098fb48a0d0002Wbv2.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2RouteTable00rtb01c63e9f4ebbd507200Mqyri = new ec2.CfnRouteTable(
      this,
      "EC2RouteTable00rtb01c63e9f4ebbd507200Mqyri",
      {
        vpcId: ec2vpc00vpc0d30a8e41d677bf7900mlzDm.ref,
        tags: [
          {
            value: "doorway",
            key: "ProjectID",
          },
          {
            value: `doorway-${props.environment}:Data`,
            key: "Name",
          },
          {
            value: props.environment,
            key: "Workspace",
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
            value: "Doorway Housing Project",
            key: "Project",
          },
          {
            value: props.environment,
            key: "Environment",
          },
        ],
      },
    );
    ec2RouteTable00rtb01c63e9f4ebbd507200Mqyri.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2RouteTable00rtb0f73f98d815062014004pnsE = new ec2.CfnRouteTable(
      this,
      "EC2RouteTable00rtb0f73f98d815062014004pnsE",
      {
        vpcId: ec2vpc00vpc0d30a8e41d677bf7900mlzDm.ref,
        tags: [
          {
            value: "doorway",
            key: "ProjectID",
          },
          {
            value: props.environment,
            key: "Workspace",
          },
          {
            value: props.environment,
            key: "Environment",
          },
          {
            value: "Doorway Housing Project",
            key: "Project",
          },
          {
            value: "doorway-fellowship-eng-team@google.com",
            key: "Owner",
          },
          {
            value: `doorway-${props.environment}:App`,
            key: "Name",
          },
          {
            value: "Bloom Housing Instance",
            key: "Application",
          },
        ],
      },
    );
    ec2RouteTable00rtb0f73f98d815062014004pnsE.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2SecurityGroup00sg01e58067e38d428c300q5rqX =
      new ec2.CfnSecurityGroup(
        this,
        "EC2SecurityGroup00sg01e58067e38d428c300q5rqX",
        {
          groupDescription:
            "Allow TLS inbound traffic and all outbound traffic",
          groupName: `doorway-${props.environment}__db_sg`,
          vpcId: ec2vpc00vpc0d30a8e41d677bf7900mlzDm.ref,
          securityGroupIngress: [
            {
              cidrIp: "10.2.3.0/24",
              ipProtocol: "tcp",
              fromPort: 5432,
              toPort: 5432,
            },
            {
              cidrIp: "10.2.5.0/24",
              ipProtocol: "tcp",
              fromPort: 5432,
              toPort: 5432,
            },
            {
              cidrIp: "10.2.1.0/24",
              ipProtocol: "tcp",
              fromPort: 5432,
              toPort: 5432,
            },
            {
              cidrIp: "10.2.2.0/24",
              ipProtocol: "tcp",
              fromPort: 5432,
              toPort: 5432,
            },
            {
              cidrIp: "10.2.0.0/24",
              ipProtocol: "tcp",
              fromPort: 5432,
              toPort: 5432,
            },
            {
              cidrIp: "10.2.4.0/24",
              ipProtocol: "tcp",
              fromPort: 5432,
              toPort: 5432,
            },
          ],
          securityGroupEgress: [
            {
              cidrIp: "0.0.0.0/0",
              ipProtocol: "-1",
              fromPort: -1,
              toPort: -1,
            },
          ],
          tags: [
            {
              value: "doorway",
              key: "ProjectID",
            },
            {
              value: props.environment,
              key: "Environment",
            },
            {
              value: `doorway-${props.environment}__db_sg`,
              key: "Name",
            },
            {
              value: props.environment,
              key: "Workspace",
            },
            {
              value: "Doorway Housing Project",
              key: "Project",
            },
            {
              value: "Bloom Housing Instance",
              key: "Application",
            },
            {
              value: "doorway-fellowship-eng-team@google.com",
              key: "Owner",
            },
          ],
        },
      );
    ec2SecurityGroup00sg01e58067e38d428c300q5rqX.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2SecurityGroup00sg0578cc8f2338aff8100oOsWf =
      new ec2.CfnSecurityGroup(
        this,
        "EC2SecurityGroup00sg0578cc8f2338aff8100oOSWf",
        {
          groupDescription:
            "Allow TLS inbound traffic and all outbound traffic",
          groupName: `doorway-${props.environment}__ecs_sg`,
          vpcId: ec2vpc00vpc0d30a8e41d677bf7900mlzDm.ref,
          securityGroupIngress: [
            {
              cidrIp: "10.2.1.0/24",
              ipProtocol: "tcp",
              fromPort: 3001,
              toPort: 3001,
            },
            {
              cidrIp: "10.2.0.0/24",
              ipProtocol: "tcp",
              fromPort: 3001,
              toPort: 3001,
            },
            {
              cidrIp: "10.2.2.0/24",
              ipProtocol: "tcp",
              fromPort: 3001,
              toPort: 3001,
            },
            {
              cidrIp: "10.2.3.0/24",
              ipProtocol: "tcp",
              fromPort: 3001,
              toPort: 3001,
            },
            {
              cidrIp: "10.2.4.0/24",
              ipProtocol: "tcp",
              fromPort: 3001,
              toPort: 3001,
            },
            {
              cidrIp: "10.2.5.0/24",
              ipProtocol: "tcp",
              fromPort: 3001,
              toPort: 3001,
            },
            {
              cidrIp: "10.2.3.0/24",
              ipProtocol: "tcp",
              fromPort: 3000,
              toPort: 3000,
            },
            {
              cidrIp: "10.2.0.0/24",
              ipProtocol: "tcp",
              fromPort: 3000,
              toPort: 3000,
            },
            {
              cidrIp: "10.2.2.0/24",
              ipProtocol: "tcp",
              fromPort: 3000,
              toPort: 3000,
            },
            {
              cidrIp: "10.2.1.0/24",
              ipProtocol: "tcp",
              fromPort: 3000,
              toPort: 3000,
            },
            {
              cidrIp: "10.2.5.0/24",
              ipProtocol: "tcp",
              fromPort: 3000,
              toPort: 3000,
            },
            {
              cidrIp: "10.2.4.0/24",
              ipProtocol: "tcp",
              fromPort: 3000,
              toPort: 3000,
            },
            {
              cidrIp: "10.2.0.0/24",
              ipProtocol: "tcp",
              fromPort: 3100,
              toPort: 3100,
            },
            {
              cidrIp: "10.2.1.0/24",
              ipProtocol: "tcp",
              fromPort: 3100,
              toPort: 3100,
            },
            {
              cidrIp: "10.2.3.0/24",
              ipProtocol: "tcp",
              fromPort: 3100,
              toPort: 3100,
            },
            {
              cidrIp: "10.2.5.0/24",
              ipProtocol: "tcp",
              fromPort: 3100,
              toPort: 3100,
            },
            {
              cidrIp: "10.2.4.0/24",
              ipProtocol: "tcp",
              fromPort: 3100,
              toPort: 3100,
            },
            {
              cidrIp: "10.2.2.0/24",
              ipProtocol: "tcp",
              fromPort: 3100,
              toPort: 3100,
            },
          ],
          securityGroupEgress: [
            {
              cidrIp: "0.0.0.0/0",
              ipProtocol: "-1",
              fromPort: -1,
              toPort: -1,
            },
          ],
          tags: [
            {
              value: "Bloom Housing Instance",
              key: "Application",
            },
            {
              value: `doorway-${props.environment}__ecs_sg`,
              key: "Name",
            },
            {
              value: props.environment,
              key: "Environment",
            },
            {
              value: "doorway",
              key: "ProjectID",
            },
            {
              value: "Doorway Housing Project",
              key: "Project",
            },
            {
              value: "doorway-fellowship-eng-team@google.com",
              key: "Owner",
            },
            {
              value: props.environment,
              key: "Workspace",
            },
          ],
        },
      );
    ec2SecurityGroup00sg0578cc8f2338aff8100oOsWf.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2SecurityGroup00sg05a03eadbf04237eb00mwIzs =
      new ec2.CfnSecurityGroup(
        this,
        "EC2SecurityGroup00sg05a03eadbf04237eb00mwIZS",
        {
          groupDescription:
            "Allow TLS inbound traffic and all outbound traffic",
          groupName: `doorway-${props.environment}_public_https`,
          vpcId: ec2vpc00vpc0d30a8e41d677bf7900mlzDm.ref,
          securityGroupIngress: [
            {
              cidrIp: "0.0.0.0/0",
              ipProtocol: "tcp",
              fromPort: 80,
              toPort: 80,
            },
            {
              cidrIp: "0.0.0.0/0",
              ipProtocol: "tcp",
              fromPort: 443,
              toPort: 443,
            },
          ],
          securityGroupEgress: [
            {
              cidrIp: "0.0.0.0/0",
              ipProtocol: "-1",
              fromPort: -1,
              toPort: -1,
            },
          ],
          tags: [
            {
              value: `doorway-${props.environment}_public_https`,
              key: "Name",
            },
            {
              value: props.environment,
              key: "Workspace",
            },
            {
              value: "Bloom Housing Instance",
              key: "Application",
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
              value: "Doorway Housing Project",
              key: "Project",
            },
            {
              value: "doorway",
              key: "ProjectID",
            },
          ],
        },
      );
    ec2SecurityGroup00sg05a03eadbf04237eb00mwIzs.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2SecurityGroup00sg08ba7ae673ea5104a004LzHk =
      new ec2.CfnSecurityGroup(
        this,
        "EC2SecurityGroup00sg08ba7ae673ea5104a004LzHK",
        {
          groupDescription:
            "Allow TLS inbound traffic and all outbound traffic",
          groupName: `doorway-${props.environment}_local_https`,
          vpcId: ec2vpc00vpc0d30a8e41d677bf7900mlzDm.ref,
          securityGroupIngress: [
            {
              cidrIp: "10.2.0.0/24",
              ipProtocol: "tcp",
              fromPort: 443,
              toPort: 443,
            },
            {
              cidrIp: "10.2.2.0/24",
              ipProtocol: "tcp",
              fromPort: 443,
              toPort: 443,
            },
            {
              cidrIp: "10.2.4.0/24",
              ipProtocol: "tcp",
              fromPort: 443,
              toPort: 443,
            },
            {
              cidrIp: "10.2.1.0/24",
              ipProtocol: "tcp",
              fromPort: 443,
              toPort: 443,
            },
            {
              cidrIp: "10.2.5.0/24",
              ipProtocol: "tcp",
              fromPort: 443,
              toPort: 443,
            },
            {
              cidrIp: "10.2.3.0/24",
              ipProtocol: "tcp",
              fromPort: 443,
              toPort: 443,
            },
          ],
          securityGroupEgress: [
            {
              cidrIp: "0.0.0.0/0",
              ipProtocol: "-1",
              fromPort: -1,
              toPort: -1,
            },
          ],
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
              value: props.environment,
              key: "Workspace",
            },
            {
              value: `doorway-${props.environment}_local_https`,
              key: "Name",
            },
            {
              value: "Bloom Housing Instance",
              key: "Application",
            },
            {
              value: "doorway-fellowship-eng-team@google.com",
              key: "Owner",
            },
          ],
        },
      );
    ec2SecurityGroup00sg08ba7ae673ea5104a004LzHk.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2SecurityGroup00sg0d7fd6fa7b475f57500CDbwW =
      new ec2.CfnSecurityGroup(
        this,
        "EC2SecurityGroup00sg0d7fd6fa7b475f57500CDbwW",
        {
          groupDescription: `Enable access to doorway-${props.environment} database`,
          groupName: `doorway-${props.environment}-db`,
          vpcId: ec2vpc00vpc0d30a8e41d677bf7900mlzDm.ref,
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
              value: "doorway-fellowship-eng-team@google.com",
              key: "Owner",
            },
            {
              value: "Bloom Housing Instance",
              key: "Application",
            },
            {
              value: props.environment,
              key: "Environment",
            },
            {
              value: props.environment,
              key: "Workspace",
            },
          ],
        },
      );
    ec2SecurityGroup00sg0d7fd6fa7b475f57500CDbwW.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2SecurityGroup00sg0e53595eee49d420100VWoZv =
      new ec2.CfnSecurityGroup(
        this,
        "EC2SecurityGroup00sg0e53595eee49d420100VWoZV",
        {
          groupDescription: `Import Listings Task (doorway-${props.environment})`,
          groupName: `doorway-${props.environment}-import-listings-task`,
          vpcId: ec2vpc00vpc0d30a8e41d677bf7900mlzDm.ref,
          securityGroupEgress: [
            {
              cidrIp: "0.0.0.0/0",
              ipProtocol: "tcp",
              description:
                "Allow full access to HTTP from task import-listings",
              fromPort: 80,
              toPort: 80,
            },
            {
              cidrIp: "0.0.0.0/0",
              ipProtocol: "tcp",
              description: "Allow import-listings task to access database",
              fromPort: 5432,
              toPort: 5432,
            },
            {
              cidrIp: "0.0.0.0/0",
              ipProtocol: "tcp",
              description:
                "Allow full access to HTTPS from task import-listings",
              fromPort: 443,
              toPort: 443,
            },
          ],
          tags: [
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
            {
              value: "Doorway Housing Project",
              key: "Project",
            },
            {
              value: "doorway",
              key: "ProjectID",
            },
          ],
        },
      );
    ec2SecurityGroup00sg0e53595eee49d420100VWoZv.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2Subnet00subnet00431dee991c12f0200emE9m = new ec2.CfnSubnet(
      this,
      "EC2Subnet00subnet00431dee991c12f0200emE9m",
      {
        vpcId: ec2vpc00vpc0d30a8e41d677bf7900mlzDm.ref,
        mapPublicIpOnLaunch: false,
        enableDns64: false,
        availabilityZoneId: "usw1-az1",
        privateDnsNameOptionsOnLaunch: {
          EnableResourceNameDnsARecord: false,
          HostnameType: "ip-name",
          EnableResourceNameDnsAAAARecord: false,
        },
        cidrBlock: "10.2.4.0/24",
        ipv6Native: false,
        tags: [
          {
            value: "doorway-fellowship-eng-team@google.com",
            key: "Owner",
          },
          {
            value: props.environment,
            key: "Environment",
          },
          {
            value: "Doorway Housing Project",
            key: "Project",
          },
          {
            value: `doorway-${props.environment}:Data 0`,
            key: "Name",
          },
          {
            value: "doorway",
            key: "ProjectID",
          },
          {
            value: props.environment,
            key: "Workspace",
          },
          {
            value: "Bloom Housing Instance",
            key: "Application",
          },
        ],
      },
    );
    ec2Subnet00subnet00431dee991c12f0200emE9m.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2Subnet00subnet089ba928efdadc4ea00fYzO5 = new ec2.CfnSubnet(
      this,
      "EC2Subnet00subnet089ba928efdadc4ea00fYzO5",
      {
        vpcId: ec2vpc00vpc0d30a8e41d677bf7900mlzDm.ref,
        mapPublicIpOnLaunch: false,
        enableDns64: false,
        availabilityZoneId: "usw1-az3",
        privateDnsNameOptionsOnLaunch: {
          EnableResourceNameDnsARecord: false,
          HostnameType: "ip-name",
          EnableResourceNameDnsAAAARecord: false,
        },
        cidrBlock: "10.2.3.0/24",
        ipv6Native: false,
        tags: [
          {
            value: props.environment,
            key: "Environment",
          },
          {
            value: "Bloom Housing Instance",
            key: "Application",
          },
          {
            value: `doorway-${props.environment}:App 1`,
            key: "Name",
          },
          {
            value: "Doorway Housing Project",
            key: "Project",
          },
          {
            value: props.environment,
            key: "Workspace",
          },
          {
            value: "doorway",
            key: "ProjectID",
          },
          {
            value: "doorway-fellowship-eng-team@google.com",
            key: "Owner",
          },
        ],
      },
    );
    ec2Subnet00subnet089ba928efdadc4ea00fYzO5.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2Subnet00subnet0cc003b8490ec636200g9rRs = new ec2.CfnSubnet(
      this,
      "EC2Subnet00subnet0cc003b8490ec636200g9rRs",
      {
        vpcId: ec2vpc00vpc0d30a8e41d677bf7900mlzDm.ref,
        mapPublicIpOnLaunch: false,
        enableDns64: false,
        availabilityZoneId: "usw1-az1",
        privateDnsNameOptionsOnLaunch: {
          EnableResourceNameDnsARecord: false,
          HostnameType: "ip-name",
          EnableResourceNameDnsAAAARecord: false,
        },
        cidrBlock: "10.2.2.0/24",
        ipv6Native: false,
        tags: [
          {
            value: `doorway-${props.environment}:App 0`,
            key: "Name",
          },
          {
            value: "doorway",
            key: "ProjectID",
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
          {
            value: props.environment,
            key: "Environment",
          },
          {
            value: "Doorway Housing Project",
            key: "Project",
          },
        ],
      },
    );
    ec2Subnet00subnet0cc003b8490ec636200g9rRs.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2Subnet00subnet0edef87ce8b9ccd6200Y0ObS = new ec2.CfnSubnet(
      this,
      "EC2Subnet00subnet0edef87ce8b9ccd6200Y0ObS",
      {
        vpcId: ec2vpc00vpc0d30a8e41d677bf7900mlzDm.ref,
        mapPublicIpOnLaunch: false,
        enableDns64: false,
        availabilityZoneId: "usw1-az1",
        privateDnsNameOptionsOnLaunch: {
          EnableResourceNameDnsARecord: false,
          HostnameType: "ip-name",
          EnableResourceNameDnsAAAARecord: false,
        },
        cidrBlock: "10.2.0.0/24",
        ipv6Native: false,
        tags: [
          {
            value: props.environment,
            key: "Environment",
          },
          {
            value: `doorway-${props.environment}:Public 0`,
            key: "Name",
          },
          {
            value: "doorway-fellowship-eng-team@google.com",
            key: "Owner",
          },
          {
            value: "Doorway Housing Project",
            key: "Project",
          },
          {
            value: "doorway",
            key: "ProjectID",
          },
          {
            value: props.environment,
            key: "Workspace",
          },
          {
            value: "Bloom Housing Instance",
            key: "Application",
          },
        ],
      },
    );
    ec2Subnet00subnet0edef87ce8b9ccd6200Y0ObS.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2Subnet00subnet0f08efdbfc84ae85000CVlrw = new ec2.CfnSubnet(
      this,
      "EC2Subnet00subnet0f08efdbfc84ae85000CVlrw",
      {
        vpcId: ec2vpc00vpc0d30a8e41d677bf7900mlzDm.ref,
        mapPublicIpOnLaunch: false,
        enableDns64: false,
        availabilityZoneId: "usw1-az3",
        privateDnsNameOptionsOnLaunch: {
          EnableResourceNameDnsARecord: false,
          HostnameType: "ip-name",
          EnableResourceNameDnsAAAARecord: false,
        },
        cidrBlock: "10.2.5.0/24",
        ipv6Native: false,
        tags: [
          {
            value: props.environment,
            key: "Environment",
          },
          {
            value: "doorway-fellowship-eng-team@google.com",
            key: "Owner",
          },
          {
            value: `doorway-${props.environment}:Data 1`,
            key: "Name",
          },
          {
            value: "doorway",
            key: "ProjectID",
          },
          {
            value: "Bloom Housing Instance",
            key: "Application",
          },
          {
            value: "Doorway Housing Project",
            key: "Project",
          },
          {
            value: props.environment,
            key: "Workspace",
          },
        ],
      },
    );
    ec2Subnet00subnet0f08efdbfc84ae85000CVlrw.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2Subnet00subnet0f50debb24527dce100gM7p3 = new ec2.CfnSubnet(
      this,
      "EC2Subnet00subnet0f50debb24527dce100gM7P3",
      {
        vpcId: ec2vpc00vpc0d30a8e41d677bf7900mlzDm.ref,
        mapPublicIpOnLaunch: false,
        enableDns64: false,
        availabilityZoneId: "usw1-az3",
        privateDnsNameOptionsOnLaunch: {
          EnableResourceNameDnsARecord: false,
          HostnameType: "ip-name",
          EnableResourceNameDnsAAAARecord: false,
        },
        cidrBlock: "10.2.1.0/24",
        ipv6Native: false,
        tags: [
          {
            value: "Doorway Housing Project",
            key: "Project",
          },
          {
            value: props.environment,
            key: "Workspace",
          },
          {
            value: "Bloom Housing Instance",
            key: "Application",
          },
          {
            value: `doorway-${props.environment}:Public 1`,
            key: "Name",
          },
          {
            value: "doorway-fellowship-eng-team@google.com",
            key: "Owner",
          },
          {
            value: props.environment,
            key: "Environment",
          },
          {
            value: "doorway",
            key: "ProjectID",
          },
        ],
      },
    );
    ec2Subnet00subnet0f50debb24527dce100gM7p3.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2SubnetNetworkAclAssociation00aclassoc0955bf7d6da6e99c400Somim =
      new ec2.CfnSubnetNetworkAclAssociation(
        this,
        "EC2SubnetNetworkAclAssociation00aclassoc0955bf7d6da6e99c400SOMIM",
        {
          networkAclId: ec2NetworkAcl00acl033ab3098fb48a0d0002Wbv2.ref,
          subnetId: ec2Subnet00subnet089ba928efdadc4ea00fYzO5.ref,
        },
      );
    ec2SubnetNetworkAclAssociation00aclassoc0955bf7d6da6e99c400Somim.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2SubnetNetworkAclAssociation00aclassoc0aecf12e4367b7f2100LllRj =
      new ec2.CfnSubnetNetworkAclAssociation(
        this,
        "EC2SubnetNetworkAclAssociation00aclassoc0aecf12e4367b7f2100LllRJ",
        {
          networkAclId: ec2NetworkAcl00acl033ab3098fb48a0d0002Wbv2.ref,
          subnetId: ec2Subnet00subnet00431dee991c12f0200emE9m.ref,
        },
      );
    ec2SubnetNetworkAclAssociation00aclassoc0aecf12e4367b7f2100LllRj.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2SubnetRouteTableAssociation00rtbassoc0a41ee1b2db373618006Q8lm =
      new ec2.CfnSubnetRouteTableAssociation(
        this,
        "EC2SubnetRouteTableAssociation00rtbassoc0a41ee1b2db373618006Q8lm",
        {
          routeTableId: ec2RouteTable00rtb01c63e9f4ebbd507200Mqyri.ref,
          subnetId: ec2Subnet00subnet00431dee991c12f0200emE9m.ref,
        },
      );
    ec2SubnetRouteTableAssociation00rtbassoc0a41ee1b2db373618006Q8lm.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
    const ec2SubnetRouteTableAssociation00rtbassoc0d606a2505f3234d000czsQg =
      new ec2.CfnSubnetRouteTableAssociation(
        this,
        "EC2SubnetRouteTableAssociation00rtbassoc0d606a2505f3234d000czsQG",
        {
          routeTableId: ec2RouteTable00rtb0f73f98d815062014004pnsE.ref,
          subnetId: ec2Subnet00subnet089ba928efdadc4ea00fYzO5.ref,
        },
      );
    ec2SubnetRouteTableAssociation00rtbassoc0d606a2505f3234d000czsQg.cfnOptions.deletionPolicy =
      cdk.CfnDeletionPolicy.RETAIN;
  }
}
