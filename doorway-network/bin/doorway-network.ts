#!/usr/bin/env node
import * as cdk from "aws-cdk-lib";
import "source-map-support/register";
import { DoorwayNetworkStack } from "../lib/doorway-network-stack";
const app = new cdk.App();
const environment =
  process.env.ENVIRONMENT == undefined ? "dev" : process.env.ENVIRONMENT;
new DoorwayNetworkStack(app, `DoorwayNetwork-${environment}`, {
  environment: environment,
});
