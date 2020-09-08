FROM algebr/openface:latest

# Install Ruby using ruby-build
WORKDIR /tmp
RUN apt-get update
RUN apt-get install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev -y
RUN git clone https://github.com/rbenv/ruby-build.git
RUN PREFIX=/usr/local ./ruby-build/install.sh
RUN ruby-build 2.7.1 /usr/local
RUN gem install bundler
RUN rm -r ruby-build

# Setup the tool
WORKDIR /home/majima
COPY ./src ./src
WORKDIR /home/majima/src
RUN bundle install

# The base OpenFace image uses an ENTRYPOINT which causes issues.
# See: https://stackoverflow.com/questions/41207522/docker-override-or-remove-entrypoint-from-a-base-image
ENTRYPOINT ["/usr/bin/env"]
CMD ["./one_eyed_daemon.rb"]
