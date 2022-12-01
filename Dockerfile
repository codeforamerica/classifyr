# syntax=docker/dockerfile:1
FROM ruby:3.1.2

RUN apt-get update -q && \
    apt-get upgrade -q -y && \
    apt-get install -q -y nodejs postgresql-client software-properties-common

# Install yq for convertring CSV to JSON on the command line.
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && \
    chmod a+x /usr/local/bin/yq

# Install xsv for faster CSV parsing.
RUN XSV_VERSION=$(curl -s "https://api.github.com/repos/BurntSushi/xsv/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+') && \
    curl -Lo xsv.tar.gz "https://github.com/BurntSushi/xsv/releases/latest/download/xsv-${XSV_VERSION}-x86_64-unknown-linux-musl.tar.gz" && \
    tar xf xsv.tar.gz --directory /usr/local/bin && \
    rm -rf xsv.tar.gz

WORKDIR /opt/classifyr
COPY . /opt/classifyr
RUN bundle install
RUN rails assets:precompile

# Remove lock file from installed dependencies. Bundler doesn't use them but they
# can be flagged by scanning services such as AWS Inspector.
RUN find /usr/local/bundle -name Gemfile.lock -delete

# Add a script to be executed every time the container starts.
COPY scripts/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]
