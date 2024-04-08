#! /bin/bash

cd "$(dirname $0)"

DATE=$(date -Is)
echo "getting test db url..."
TEST_URL=$(./url.sh test)
echo "dumping test db..."
pg_dump --data-only $TEST_URL > "./dumps/test/${DATE}.sql"
echo "> ./dumps/test/${DATE}.sql"
echo "deleting dev db..."
echo "delete from text;" | psql -1 palindr
echo "delete from norm;" | psql -1 palindr
echo "restoring test db into dev db..."
psql -1 palindr < ./dumps/test/${DATE}.sql
