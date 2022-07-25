# README

Data classification tool developed for the Reimagine911 project.

## System Requirements

You'll want to ensure you have the following already installed on your local machine before getting started.

- **Ruby**: Version 3.1.2 as specified in the `.ruby-version` file.
- **Bundler**: Version 2.3.7+.
- **PostgreSQL**: Version 12+.

For reference, the project is using Rails 7.

## Installation

You can set things up manually by going through this section or use Docker (see next section).

1. Pull the code

```
git clone git@github.com:codeforamerica/classifyr.git && cd classifyr
```

2. Install dependencies

```
bundle install
```

3. Set up the database

```
rails db:prepare
```

4. Run the tests

```
rspec
```

5. Start the server

```
./bin/dev
```

## Docker

This project includes a Dockerfile for the web app as well as a docker compose
file that can be used to set up a full local stack for development and testing.
These configurations are based on the official [Docker documentation for'
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
docker compose run web rake db:create
docker compose run web rake db:migrate
docker compose run web rake assets:precompile
```

You should then be able to connect to the classifyr via http://localhost:3000/.

[1]: https://docs.docker.com/samples/rails/
[2]: https://docs.docker.com/compose/
[3]: https://github.com/abiosoft/colima

## Tests (how to run)

Use the following command to run the tests:

```
rspec
```

```
Finished in 0.86675 seconds (files took 2.32 seconds to load)
11 examples, 0 failures
```

## Linting

We use Rubocop with a [custom config](.rubocop.yml) for linting. Run the following command to check the code:

```
rubocop
```

Add `-a` or `-A` to automatically fix correctable issues.

## Deployment

WIP.

## Contributing

We follow a very simple development workflow: https://guides.github.com/introduction/flow/

> GitHub flow is a lightweight, branch-based workflow. The GitHub flow is useful for everyone, not just developers.

1. Check out the `main` branch and pull down the latest code.
2. Create a new branch off of the latest from `main` prefixed with your initials: td-new-feature.
3. Work on your feature.
4. When you're done with your feature, create a pull request and request a review from another developer. Please follow the pull request template. Opening a PR will automatically run the tests and linting, make sure everything is passing.
5. Fix up your PR if needed and "squash and merge" it once approved.
