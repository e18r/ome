#! /bin/bash

cd "$(dirname $0)"

if [[ ("$1" != "dev" && "$1" != "test" && "$1" != "prod") \
   || ("$1" != "dev" && "$2" != "heroku" && "$2" != "neon") ]]; then
    echo "usage: ./migrate.sh ENV [TYPE]"
    echo
    echo "ENV:  dev|test|prod"
    echo "TYPE: heroku|neon (only for test and prod environments)"
    exit 1
fi

ENV=$1
TYPE=$2
echo "getting ${TYPE} ${ENV} db url..."
URL=$(./url.sh ${ENV} ${TYPE})
for MIGRATION in ./migrations/*.sql; do
    # TODO: partial migration
    echo "applying ${MIGRATION} to ${TYPE} ${ENV} db..."
    psql -1 ${URL} -f ${MIGRATION}
done
