import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
export interface DoorwayParametersStackProps extends cdk.StackProps {
    environment: string;
}
export declare class DoorwayParametersStack extends cdk.Stack {
    constructor(scope: Construct, id: string, props?: DoorwayParametersStackProps);
}
