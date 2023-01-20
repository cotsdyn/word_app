#!/bin/bash
set -e

# get the IDs of our subnets
subnets=`aws ec2 describe-subnets --filter --query 'Subnets[].SubnetId'`

# get the ID of our 'default' securitygroup
securitygroups=`aws ec2 describe-security-groups --filters Name=group-name,Values='default' --query 'SecurityGroups[].GroupId'`

# run the task, on our ECS Fargate cluster
aws ecs run-task \
	--task-definition db_init \
	--cluster ecs \
	--launch-type FARGATE   \
	--network-configuration "awsvpcConfiguration={subnets=${subnets},securityGroups=${securitygroups},assignPublicIp=ENABLED}" \
	> /dev/null

aws ecs list-tasks --cluster ecs
