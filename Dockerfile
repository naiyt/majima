FROM algebr/openface:latest

# Install Ruby using ruby-build
# (Not using the Ruby image, because we need to build this off the openface image instead)
WORKDIR /tmp
RUN apt-get update
RUN apt-get install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev -y
RUN git clone https://github.com/rbenv/ruby-build.git
RUN PREFIX=/usr/local ./ruby-build/install.sh
RUN ruby-build 2.7.2 /usr/local
RUN gem install bundler
RUN rm -r ruby-build


# Install Dependencies

RUN apt install software-properties-common -y
# Needed for ffmpeg
RUN add-apt-repository ppa:mc3man/trusty-media -y
RUN apt-get update && apt-get install -y \
  curl \
  build-essential \
  libpq-dev \
  ffmpeg \
  postgresql-client &&\
  curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y nodejs yarn

# Setup app
WORKDIR /majima
COPY Gemfile /majima/Gemfile
COPY Gemfile.lock /majima/Gemfile.lock
RUN bundle install
COPY . /majima

# Add a script to be executed every time the container starts
COPY bin/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 4000

ENV OPENFACE_EXECUTABLE_PATH /home/openface-build/build/bin/FeatureExtraction

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
