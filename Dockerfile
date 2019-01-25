FROM ruby:2.3.4
RUN apt-get update -qq && apt-get install -y build-essential \
  libpq-dev libgeos-dev libgeos++-dev libproj-dev
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get install -y nodejs

ENV BUNDLE_PATH /gems
ENV GEM_PATH /gems
ENV GEM_HOME /gems
  
# Cache Gems
WORKDIR /tmp
COPY Gemfile .
COPY Gemfile.lock .

RUN gem install bundler -v '< 2' && bundle install --jobs 4

WORKDIR /app
EXPOSE 3000

