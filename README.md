# word_app
A webapp that serves "Hello, {word from a database}" upon request.

Note: This app runs in the default VPC of your AWS account.

# Requirements
You will need to have installed:
- terraform
- [awscli](https://aws.amazon.com/cli/)
- docker

# Pre-setup 
## deployment user in your AWS account
You will need to set up a deployment user in AWS:
1. Go to [the IAM console](https://console.aws.amazon.com/iam/)
2. Add a user
3. Select "Access key - programmatic access"
4. As this is a demo, attach the "AdministratorAccess" policy to this user
5. Create the user and note down the *Access Key ID* and *Secret Access Key*

## AWS credentials
run `aws configure` and give it the access details for the deployment user you just created


# Running the *word_app* service on AWS
## set up environment variables
The application deployment is configured via *environment variables* on your machine. These are used to set up the MySQL database in AWS RDS, and are passed to the word_app webapp container itself.

The environment variables you need to export in your shell are:
```
export DB_NAME=words
export DB_USERNAME=admin
export DB_PASSWORD=this-is-an-interesting-password
```

You do not need to supply DB_HOSTNAME; this is pulled automatically from the MySQL RDS instance by Terraform.

## set up infrastructure
Note: Terraform will pick up the environment variables DB_NAME, DB_USERNAME and DB_PASSWORD from your shell. To set these up, [see previous section](#environment-variables).

1. check the proposed infrastructre in AWS by running: `terraform plan`
2. if the infrastructure plan looks acceptable, apply with: `terraform apply`

Terraform will now tell you the DNS address of your new application as "ALB_dns" - save this information for later; the app needs to have container images pushed and the database loaded - see next section.

## set up containers
1. generate a temporary ECR login key for Docker: `./docker-login-ecr.sh`
2. build the Docker containers and push them to our ECR repositories: `./docker-build-and-push.sh`

## load database data
1. initialise the MySQL database: `./database-init-task.sh`
2. you can view active tasks with: `aws ecs list-tasks --cluster ecs` - when the task disappears, your DB will have been initialised

## view the application
In a web-browser, visit the address you were given as ALB_DNS.

# Information
Written in Python, using the [Flask](https://flask.palletsprojects.com/en/2.2.x/) web requests framework.
