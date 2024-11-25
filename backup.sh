#! /bin/bash

cd "$(dirname $0)"

backup() {

    ENV=$1

    if [ "${ENV}" = "test" ]; then
        ENV_UNDER="dev"
    elif [ "${ENV}" = "prod" ]; then
        ENV_UNDER="test"
    else
        echo "bad ENV"
        exit 1
    fi

    echo "getting heroku ${ENV} db url..."
    HEROKU_URL=$(./url.sh ${ENV} heroku)

    echo "dumping heroku ${ENV} db..."
    TIMESTAMP=$(date +%s)
    pg_dump --data-only ${HEROKU_URL} > ./dumps/${ENV}/${TIMESTAMP}.sql
    echo "> ./dumps/${ENV}/${TIMESTAMP}.sql"

    echo "uploading heroku ${ENV} db to gcloud..."
    BUCKET=$(jq -r .bucket.${ENV} ./settings.json)
    gcloud storage cp ./dumps/${ENV}/${TIMESTAMP}.sql gs://${BUCKET}

    echo "getting heroku ${ENV_UNDER} url..."
    HEROKU_URL_UNDER=$(./url.sh ${ENV_UNDER} heroku)

    echo "deleting data from heroku ${ENV_UNDER} db..."
    echo "delete from text;" | psql -1 ${HEROKU_URL_UNDER}
    echo "delete from norm;" | psql -1 ${HEROKU_URL_UNDER}

    echo "restoring data from heroku ${ENV} db into heroku ${ENV_UNDER} db..."
    psql -1 ${HEROKU_URL_UNDER} < ./dumps/${ENV}/${TIMESTAMP}.sql

}

backup test
backup prod
