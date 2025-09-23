# Doorway Infra

This is the deployment for the base infrastructure of the
[Doorway Housing Portal](https://github.com/metrotranscom/doorway/).

The goal of this is to define the major underlying infrastructure that is not Doorway-specific. This includes:

- **Network Infrastructure** - Including VPCs, subnets and security groups
- **Database Infrastructure** - The database server itself, the RDS subnet group and the admin login secret.
- **Service Environment Infrastructure** - Basically the ECS infrastructure
- **Global Infrastructure** - Common infrastructure required by all the environments. (The SES setup and parameters holding core information)
- **The Infrastructure Build Pipeline** - The CodePipeline process for deploying the infrastructure.

## Directory Structure

- **bin** - Location of the root [CDK](https://aws.amazon.com/cdk/) typescript files. Called by the
  cdk command-line interface. No Real infrastructure code. Just instantiates CDK Infrastructure
  stacks located in lib/cdk.
- **lib** - primary code subdirectory.
- **lib/base_infra** - Holds the underlying CDK code for the infrastucture
- **lib/pipelines** - The code to define the CodePipeline build pipeline

## Necessary workstation setup

You will need the following things set up before you work with the code in this repo:

- A Typescript IDE like VS Code.
- NodeJS - currently version 22 - I reccomend using [NVM](https://github.com/nvm-sh/nvm).
- The [AWS CLI](https://aws.amazon.com/cli/).
- The [AWS CDK](https://docs.aws.amazon.com/cdk/v2/guide/getting-started.html)
- [Yarn](https://yarnpkg.com/)

## Useful commands

- `yarn test` Perform the jest unit tests.
- `cdk synth` emits the synthesized CloudFormation template. This is also good to use on your local
  workstation to make sure your CDK code hangs together. **This doesn't touch the actual AWS
  infrastructure.**
- `cdk deploy` deploy this stack to your default AWS account/region. \_\_This impacts AWS and will
  only work if you have the proper access and have configured your AWS credentials file.
- `cdk diff` compare deployed stack with current state

## Important Notes

- `cdk deploy` will really only create the code pipeline. Once that is created, any base infrastructure changes merged to main will be applied by the pipeline
