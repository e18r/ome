#! /bin/bash

cd "$(dirname $0)"

if [ "$1" != "dev" -a "$1" != "test" -a "$1" != "prod" ]; then
    echo "usage: ./migrate.sh [dev|test|prod]"
    exit 1
fi

ENV=$1
echo "getting ${ENV} db url..."
URL=$(./url.sh ${ENV})
for MIGRATION in ./migrations/*.sql; do
    // TODO: partial migration
    echo "applying ${MIGRATION} to ${ENV} db..."
    psql -1 ${URL} -f ${MIGRATION}
done
