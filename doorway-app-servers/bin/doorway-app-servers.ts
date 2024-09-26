#!/usr/bin/env node
import * as cdk from "aws-cdk-lib";
import "source-map-support/register";
import { DoorwayApiServiceStack } from "../lib/doorway_api_service-stack";

const environment =
  process.env.ENVIRONMENT == undefined ? "dev" : process.env.ENVIRONMENT;
const app = new cdk.App();
// new DoorwayAppInfraStack(app, `DoorwayAppInfra-${environment}`, {
//   environment: environment,
// });

new DoorwayApiServiceStack(app, `DoorwayApiService-${environment}`, {
  environment: environment,
});
