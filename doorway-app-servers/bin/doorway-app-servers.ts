#!/usr/bin/env node
import * as cdk from "aws-cdk-lib";
import "source-map-support/register";
import { DoorwayAppInfraStack } from "../lib/doorway_app_infra-stack";
const environment =
  process.env.ENVIRONMENT == undefined ? "dev" : process.env.ENVIRONMENT;
const app = new cdk.App();
new DoorwayAppInfraStack(app, `DoorwayAppInfra-${environment}`, {
  environment: environment,
});
// const lbs = new DoorwayLoadBalancersStack(
//   app,
//   `DoorwayLoadBalancers-${environment}`,
//   { environment: environment },
// );
