#! /bin/bash

cd "$(dirname $0)"

if [[ "$1" != "dev" && "$1" != "test" && "$1" != "prod" ]]; then
    echo "usage: ./url.sh ENV"
    echo
    echo "ENV:  dev|test|prod"
    exit 1
fi

ENV=${1}

if [ "${ENV}" = "test" ]; then
    ENV_UNDER="dev"
elif [ "${ENV}" = "prod" ]; then
    ENV_UNDER="test"
fi

echo "getting neon ${ENV} db url..."
NEON_URL=$(./url.sh ${ENV} neon)

echo "dumping neon ${ENV} db..."
TIMESTAMP=$(date +%s)
# remove transaction_timeout directive to make it compatible with postgres <v17
pg_dump --verbose --data-only ${NEON_URL} \
    | sed "s/SET transaction_timeout.*//g" \
          > ./dumps/${ENV}/${TIMESTAMP}.sql
echo "> ./dumps/${ENV}/${TIMESTAMP}.sql"

if [ "${ENV}" != "dev" ]; then

    echo "uploading neon ${ENV} db to gcloud..."
    BUCKET=$(jq -r .bucket.${ENV} ./settings.json)
    gcloud storage cp ./dumps/${ENV}/${TIMESTAMP}.sql gs://${BUCKET}

fi

echo "getting heroku ${ENV} db url..."
HEROKU_URL=$(./url.sh ${ENV} heroku)

echo "deleting data from heroku ${ENV} db..."
echo "delete from text;" | psql -1 ${HEROKU_URL}
echo "delete from norm;" | psql -1 ${HEROKU_URL}

echo "neon ${ENV} -> heroku ${ENV}..."
psql -1 ${HEROKU_URL} < ./dumps/${ENV}/${TIMESTAMP}.sql

if [ "${ENV}" = "dev" ]; then
    exit 0
fi

echo "getting neon ${ENV_UNDER} db url..."
NEON_URL_UNDER=$(./url.sh ${ENV_UNDER} neon)

echo "deleting data from neon ${ENV_UNDER} db..."
echo "delete from text;" | psql -1 ${NEON_URL_UNDER}
echo "delete from norm;" | psql -1 ${NEON_URL_UNDER}

echo "neon ${ENV} -> neon ${ENV_UNDER}..."
psql -1 ${NEON_URL_UNDER} < ./dumps/${ENV}/${TIMESTAMP}.sql
