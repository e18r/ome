#! /bin/bash

cd "$(dirname $0)"
psql postgres -f ./db.sql
./migrate.sh dev
psql palindr -f ./privileges.sql
