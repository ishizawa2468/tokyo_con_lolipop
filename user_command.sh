#!/bin/bash

# bundle install
echo "Running bundle install..."
bundle install --deployment --without development,test --path vendor/bundle

# db:create
echo "Creating the database..."
bundle exec rails db:create

# db:migrate
echo "Running database migrations..."
bundle exec rails db:migrate

# assets:precompile
echo "Precompiling assets..."
bundle exec rails assets:precompile

# db:prod_seeds
#echo "Loading production seeds..."
#bundle exec rails db:seed

echo "Rails initialization and production seeds completed successfully."
