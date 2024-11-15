#!/usr/bin/env node
import * as cdk from "aws-cdk-lib";
import "source-map-support/register";
import { DoorwayServicesInfraPipelineStack } from "../lib/doorway-services-pipeline";
const app = new cdk.App();

new DoorwayServicesInfraPipelineStack(app, `DoorwayServicesPipelineStack`);
