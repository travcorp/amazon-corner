# VPC with public and private subnets
This CloudFormation template creates a VPC with the following features:
* Deployed in 2 availability zones in the region where stack is created
* Has public subnets connected to the internet via Internet Gateway
* Has private application subnets
    * Optionally has outbound internet traffic via NAT gateway
* Has VPC log flowing to CloudWatch with 30 day retention
* Has all it's resources tagged if applicable

The stack exports the following cross-stack parameters:
* VPC ID
    * _Project_-_Environment_-Vpc
* Public subnet IDs
    * _Project_-_Environment_-PublicSubnetZoneA
    * _Project_-_Environment_-PublicSubnetZoneB
* Application (private) subnet IDs
    * _Project_-_Environment_-AppSubnetZoneA
    * _Project_-_Environment_-AppSubnetZoneB
* Application (private) route table IDs
    * _Project_-_Environment_-AppRouteTableZoneA
    * _Project_-_Environment_-AppRouteTableZoneB
