# README

Data classification tool developed for the Reimagine911 project.

## Testing

Run the following command to start the tests.

```
bundle exec rspec
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
