DATABASE_NAME=$1

dropdb $DATABASE_NAME

createdb $DATABASE_NAME

psql $DATABASE_NAME -f $DATABASE_NAME.sql

bundle install

bundle exec ruby bowling.rb -p 4567