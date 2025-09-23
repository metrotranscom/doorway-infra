#!/usr/bin/env node
import * as cdk from "aws-cdk-lib";
import { DoorwayInfraPipelineStack } from "../lib/pipelines/doorway-infra-pipeline-stack";

const app = new cdk.App();
new DoorwayInfraPipelineStack(app, "DoorwayInfraPipelineStack", {
  githubSecret: process.env.GITHUB_SECRET || "mtc/githubSecret",
  dockerHubSecret: process.env.DOCKERHUB_SECRET || "mtc/dockerHub",
});
