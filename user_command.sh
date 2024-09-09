bundle install --deployment --without development,test --path vendor/bundle
db:create
db:migrate
assets:precompile