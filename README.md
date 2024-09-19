# Doorway Infrastructure MonoRepo

Each of the subfolders are their own project using [AWS CDK](https://aws.amazon.com/cdk/)
Each project will have its own github actions assigned to build and will trigger only when there are modifications to that sub-folder
They each deploy a discrete but large section of the necessary AWS framework.
Currently in this repo:

- A network load balancer
- SSM Parameters to store VPC and subnet information necessary to create the load balancer
