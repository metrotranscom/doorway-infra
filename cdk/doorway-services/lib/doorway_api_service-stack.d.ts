import * as cdk from "aws-cdk-lib";
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
export declare class DoorwayApiServiceStack extends cdk.Stack {
    constructor(scope: cdk.App, id: string, props?: DoorwayApiServiceStackProps);
}
