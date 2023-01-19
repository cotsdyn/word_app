#!/bin/bash
set -e

AWS_REGION=$(aws configure get default.region)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# supply Docker with a temporary login key for ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
