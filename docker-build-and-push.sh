#!/bin/bash
set -e

AWS_REGION=$(aws configure get default.region)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# build image
docker build -t word_app .

# tag and push image to our ECR repo
docker tag easelive-demo ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/word_app
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/word_app
