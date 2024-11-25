#! /bin/bash

# in order for these commands to work, set your local user's permissions:
#
# $ sudo -u postgres psql
# > create role {username} login;
#
# then, when the database is created:
#
# $ psql palindr
# > grant all privileges on all tables in schema public to {username};
# > grant all privileges on all sequences in schema public to {username};

cd "$(dirname $0)"
psql postgres -f ./db.sql
./migrate.sh dev
psql palindr -f ./privileges.sql
