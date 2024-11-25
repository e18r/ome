#! /bin/bash

# in order for these commands to work, set your local user as a superuser:
#
# $ sudo -u postgres psql
# > create role {username} login superuser;

cd "$(dirname $0)"
psql postgres -f ./db.sql
./migrate.sh dev heroku
./migrate.sh dev neon
psql palindr -f ./privileges.sql
psql palindr2 -f ./privileges.sql
