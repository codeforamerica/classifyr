# README

Data classification tool developed for the Reimagine911 project.

## System Requirements

You'll want to ensure you have the following already installed on your local
machine before getting started.

- **Ruby**: Version 3.1.2 as specified in the `.ruby-version` file.
- **Bundler**: Version 2.3.7+.
- **PostgreSQL**: Version 12+.

For reference, the project is using Rails 7.

## Quick Start

You can set things up manually by going through this section or use Docker
(see next section).

1. Pull the code

   ```bash
   git clone git@github.com:codeforamerica/classifyr.git && cd classifyr
   ```

1. Install dependencies

   ```bash
   bundle install
   ```

1. Set up the database

   ```bash
   rails db:prepare
   ```

1. Run the tests

   ```bash
   rspec
   ```

5. Start the server

   ```bash
   ./bin/dev
   ```

## Docker

This project includes a Dockerfile for the web app as well as a docker compose
file that can be used to set up a full local stack for development and testing.
These configurations are based on the official [Docker documentation for
rails][1].

You can launch the stack by running the commands below (assuming you have both
docker and [docker compose][2] installed).

If you are using a rootless docker alternative, you will first need to create
the database directory by running the following:

```bash
mkdir tmp/db
```

_Note: This has been tested on Intel Mac using both Docker Desktop and
[colima][3]._

```bash
docker compose up -d
# Note: It may take a few minutes for all services to be available.
docker compose run web rake db:prepare
docker compose run web rake assets:precompile
```

You should then be able to connect to the classifyr via http://localhost:3000/.

## Tests

Use the following command to run the tests:

```bash
rspec
```

The results should appear similar to the following:

```bash
Finished in 0.86675 seconds (files took 2.32 seconds to load)
11 examples, 0 failures
```

## Linting

We use Rubocop with a [custom config][4] for linting. Run the following command
to check the code:

```bash
rubocop
```

Add `-a` or `-A` to automatically fix correctable issues.

## Deployment

Infrastructure as Code (IaC) for deploying Classifyr on AWS can be found in the
[Reimagine911 Infrastructure][5] repository.

## Accessing the Rails console for a deployment

### Requirements

- The AWS CLI (version 2.7+). Check out this [installation guide][6] if needed.
- The [Session Manager Plugin][7].
- An IAM user that has access to the appropriate AWS account.
- An virtual MFA device configured for the user (hardware devices are not
  currently supported by the AWS API).
- The name of the ECS cluster where Classifyr is running.

### Steps

#### 1. Establish a temporary session

You will first need to establish a [temporary session][8] using your MFA device.
To do so, replace the `MFA_ARN` and `MFA_CODE` in the command below.

- `MFA_ARN` (from [AWS docs][9]): The ARN of your virtual MFA device. This value
   should be in ther format `arn:aws:iam::ACCOUNT:mfa/IAM_USER`.
- `MFA_CODE`: A temporary authentication code provided by your MFA device.

```bash
aws sts get-session-token --serial-number MFA_ARN --token-code MFA_CODE
```

This will give you temporary credentials that you can set as environment
variables or create an aws profile for. See [AWS docs for details][10].

#### 2. Getting a task ID

Now to access the Rails console, retrieve the ARN from one of the running tasks
in the dev env:

```bash
aws ecs list-tasks --cluster r911-development-web --region us-east-1
```

This will return one or more task ARNs similar to
`arn:aws:ecs:us-east-1:111111111111:task/r911-development-web/111111111111111111111111111111111`.
The string after the final slash (in this example,
"111111111111111111111111111111111") is the task id.

#### 4. Accessing the console

You can then use this ID with the following command (replace TASK_ID with the
actual ID and CLUSTER_NAME with the name of the ECS cluster):

```bash
aws ecs execute-command --region us-east-1 --interactive \
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

## Contributing

We'd love to get contributions from you! For a quick guide to getting your
system setup for developing, take a look at our Quickstart Guide above. Once
you are up and running, take a look at the [Contribution Documents][11] to see
how to get your changes merged in.

[1]: https://docs.docker.com/samples/rails/
[2]: https://docs.docker.com/compose/
[3]: https://github.com/abiosoft/colima
[4]: .rubocop.yml
[5]: https://github.com/codeforamerica/r911-infrastructure
[6]: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
[7]: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
[8]: https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/
[9]: https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/
[10]: https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/
[11]: ./CONTRIBUTING.md
