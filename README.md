# easelive-demo

A webapp that serves "Hello, {word from a database}" upon request.

# Usage

## Running in Docker
1. Locally, build the container: `docker build -t easelive-demo .`
2. Then, run the container: `docker run -it -p 5000:5000 --rm easelive-demo`

You will see server startup information and access logs on STDOUT. The container will run in the foreground until you stop or kill it.

The server should be available on http://localhost:5000

Type CTRL+C to stop the server.

## Running in AWS

# Information

Written in Python, using the [Flask](https://flask.palletsprojects.com/en/2.2.x/) web requests framework.
