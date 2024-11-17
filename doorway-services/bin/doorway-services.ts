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
new DoorwayApiServiceStack(app, `doorway-api-service-${evironment}`, {
  environment: evironment,
});
