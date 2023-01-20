#!/bin/bash
set -e

AWS_REGION=$(aws configure get default.region)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)


# build db_init image
docker build -t db_init db_init/.

# tag and push db_init image to its ECR repo
docker tag db_init ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/db_init
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/db_init


# build word_app image
docker build -t word_app word_app/.

# tag and push word_app image to its ECR repo
docker tag word_app ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/word_app
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/word_app
