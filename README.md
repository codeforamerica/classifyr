# ![Classifyr][logo]

![build status][build-status] ![security status][security-status]

Data classification tool developed by Code for America. Originally developed for
the Reimagine911 project.

## Getting started

### Quickstart with Docker

This project includes a Dockerfile for the web app as well as a
[docker compose][docker-compose] file that can be used to set up a full local
stack for development and testing. These configurations are based on the official
[Docker documentation for rails][docker-rails].

You can launch the stack by running the commands below (assuming you have both
docker and docker compose installed).

If you are using a rootless docker alternative, such as Colima, you will first
need to create the database directory by running the following:

```bash
mkdir tmp/db
```

_Note: This has been tested on Intel Mac using both Docker Desktop and
[Colima][colima]._

```bash
docker compose up -d
# Note: It may take a few minutes for all services to be available.
docker compose run web rake db:prepare
docker compose run web rake assets:precompile
```

You should then be able to connect to the Classifyr application via
http://localhost:3000/.

### Quickstart without Docker

Although the Docker method is recommended, you may prefer to setup a local
environment directly on your system. This is a more advanced option and assumes
that you are familiar with how to install and configure packages on your system.

_Note: The process below has been tested on Linux and Intel Mac systems._

Before beginning, you must have the following installed:

- **Ruby**: Ensure your version matches the one found in
[.ruby-version][.ruby-version]. We recommend using a version manager such as
[RVM][rvm].
- **Bundler**: Version 2.3.7+. 
- **PostgreSQL**: Version 12+.

If you are using a database user or password other than the defaults, you will
need to set the `RAILS_DB_USER` and `RAILS_DB_PASSWORD` environment variables.

```bash
# Install dependencies.
bundle install
# Prepare the database.
rails db:prepare
# Start the server.
./bin/dev
```

## Tests

You can run the included tests for Classifyr by executing the following:

```bash
rails spec
```

The results should appear similar to the following:

```bash
Finished in 0.86675 seconds (files took 2.32 seconds to load)
11 examples, 0 failures
```

## Linting

We use Rubocop with a [custom config][.rubocop.yml] for linting. You can execute
the following to check the code.

```bash
rails rubocop
```

Additionally, you can use `rubocop:autocorrect` (safe) or
`rubocop:autocorrect_all` (unsafe) to automatically correct certain issues.

## Deployment

Infrastructure as Code (IaC) for deploying Classifyr on AWS can be found in the
[Reimagine911 Infrastructure][r911-infra] repository.

## Accessing the Rails console for a deployment

### Requirements

- The [AWS CLI][aws-cli] (version 2.7+).
- The [Session Manager Plugin][session-manager].
- An IAM user that has access to the appropriate AWS account.
- A virtual MFA device configured for the user (hardware devices are not
  currently supported by the AWS API).
- The name of the ECS cluster where Classifyr is running.

### Steps

#### 1. Establish a temporary session

You will first need to establish a [temporary session][auth-mfa] using your MFA
device. To do so, replace the `MFA_ARN` and `MFA_CODE` in the command below.

- `MFA_ARN`: The ARN of your virtual MFA device. This value should be in the
  format `arn:aws:iam::ACCOUNT:mfa/IAM_USER`.
- `MFA_CODE`: A temporary authentication code provided by your MFA device.

```bash
aws sts get-session-token --serial-number MFA_ARN --token-code MFA_CODE
```

This will give you temporary credentials that you can set as environment
variables or create an aws profile for.

#### 2. Getting a task ID

In order to access the console, you will need run the command on a running
container. Retrieve the list of currently running tasks (ECS term for running
containers) using the command below. Replace `CLUSTER_NAME` with the name of the
ECS cluster that the application is running on:

```bash
aws ecs list-tasks --cluster CLUSTER_NAME
```

This will return one or more task ARNs similar to:

> arn:aws:ecs:us-east-1:111111111111:task/r911-development-web/111111111111111111111111111111111

The string after the final slash (in this example,
"111111111111111111111111111111111") is the task id.

#### 4. Accessing the console

You can then use the task id with the following command (replace TASK_ID with
the actual id and CLUSTER_NAME with the name of the ECS cluster):

```bash
aws ecs execute-command --interactive \
  --cluster CLUSTER_NAME \
  --task TASK_ID \
  --command "rails console"
```

#### Notes

- If `aws` complains about `execute-command` not being a valid command, be sure
  to upgrade to the latest version of `aws-cli` (should be 2.7+). You can check
  your version with `aws --version`.
- If you're using named profiles, don't forget to add the option for it at the
  end of each command (`--profile my-profile`).
- If you don't have a default region set, you will need to specify the region
  for each command using `--region REGION`.

## Contributing

We'd love to get contributions from you! For a quick guide to getting your
system setup for developing, take a look at [Getting started][getting-started]
above. Once you are up and running, take a look at
[CONTRIBUTING.md][contributing] to see how you can contribute your changes.

[build-status]: https://github.com/codeforamerica/classifyr/actions/workflows/main-checks.yml/badge.svg
[security-status]: https://github.com/codeforamerica/classifyr/actions/workflows/codeql-analysis.yml/badge.svg
[docker-compose]: https://docs.docker.com/compose/
[logo]: ./app/assets/images/classifyr.svg
[docker-rails]: https://docs.docker.com/samples/rails/
[colima]: https://github.com/abiosoft/colima
[.ruby-version]: .ruby-version
[rvm]: https://rvm.io/
[.rubocop.yml]: .rubocop.yml
[r911-infra]: https://github.com/codeforamerica/r911-infrastructure
[aws-cli]: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
[session-manager]: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
[auth-mfa]: https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/
[getting-started]: #getting-started
[contributing]: CONTRIBUTING.md
