#!/bin/sh  
set -e
sleep 3
echo 'create db'
bundle exec rake db:create  RAILS_ENV=production
echo 'migration'
bundle exec rake db:migrate RAILS_ENV=production
echo 'rails s'
bundle exec rails s -p 80 -b '0.0.0.0' -e production
