#!/usr/bin/env node
import * as cdk from "aws-cdk-lib";
import "source-map-support/register";
import { DoorwayParametersStack } from "../lib/doorway-parameters-stack";
import { DoorwayApiServiceStack } from "../lib/doorway_api_service-stack";
const evironment = process.env.ENVIRONMENT || "dev";
const app = new cdk.App();
new DoorwayParametersStack(app, `doorway-parameters-${evironment}`, {
  environment: evironment,
});
new DoorwayApiServiceStack(app, `DoorwayApiService-${evironment}`, {
  environment: evironment,
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT || "none",
    region: process.env.CDK_DEFAULT_REGION || "none",
  },
});
