FROM ruby:2.6.6-alpine

ENV APP_PATH /home/app
ENV BUNDLE_VERSION 2.1.4
ENV BUNDLE_PATH /usr/local/bundle/gems
ENV TMP_PATH /tmp/
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_PORT 3000

# copy entrypoint scripts and grant execution permissions
COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

RUN apk add --no-cache bash && \
  adduser -S -h /home/app app

# install dependencies for application
RUN apk -U add --no-cache \
build-base \
git \
postgresql-dev \
postgresql-client \
libxml2-dev \
libxslt-dev \
nodejs \
yarn \
imagemagick \
tzdata \
sqlite-dev \
less \
&& rm -rf /home/cache/apk/* \
&& mkdir -p $APP_PATH 

RUN gem install bundler --version "$BUNDLE_VERSION" \
&& rm -rf $GEM_HOME/cache/*

ADD Gemfile /home/app/Gemfile
ADD Gemfile.lock /home/app/Gemfile.lock

WORKDIR /home/app
RUN  bundle install

ADD config.ru /home/app/config.ru
ADD Rakefile /home/app/Rakefile
ADD bin /home/app/bin
ADD lib /home/app/lib
ADD vendor /home/app/vendor
ADD db/migrate /home/app/db/migrate
ADD db/schema.rb /home/app/db/schema.rb
ADD db/seeds.rb /home/app/db/seeds.rb
ADD config /home/app/config
ADD config/database.yml /home/app/config/database.yml
ADD app /home/app/app
ADD package.json /home/app/package.json
ADD yarn.lock /home/app/yarn.lock
ADD public/packs /home/app/public/packs


# navigate to app directory

EXPOSE $RAILS_PORT

ENTRYPOINT [ "bundle", "exec", "rails", "s", "-b", "0.0.0.0"]

