#!/bin/sh

set -e

echo "Environment: $RAILS_ENV"

# Remove pre-existing puma/passenger server.pid
rm -f $APP_PATH/tmp/pids/server.pid

# run passed commands
bundle exec rake db:migrate
#bundle exec rake assets:precompile

if [ "$ROLE"x == 'api'x ]; then
  bundle exec rails s -p 3000 -b 0.0.0.0
elif [ "$ROLE"x == 'worker'x ]; then
  bundle exec sidekiq
fi
