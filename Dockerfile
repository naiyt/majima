FROM ruby:2.7

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /majima
COPY Gemfile /majima/Gemfile
COPY Gemfile.lock /majima/Gemfile.lock
RUN bundle install
COPY . /majima

# Add Yarn repository
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -y

# Install Yarn
RUN apt-get install yarn -y

# Add a script to be executed every time the container starts.
COPY bin/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
