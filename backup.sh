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

    echo "getting ${ENV} db url..."
    URL=$(./url.sh ${ENV})

    echo "dumping ${ENV} db..."
    TIMESTAMP=$(date +%s)
    pg_dump --data-only ${URL} > ./dumps/${ENV}/${TIMESTAMP}.sql
    echo "> ./dumps/${ENV}/${TIMESTAMP}.sql"

    echo "uploading ${ENV} db to gcloud..."
    BUCKET=$(jq -r .bucket.${ENV} ./settings.json)
    gcloud storage cp ./dumps/${ENV}/${TIMESTAMP}.sql gs://${BUCKET}

    echo "getting ${ENV_UNDER} url..."
    URL_UNDER=$(./url.sh $ENV_UNDER)

    echo "deleting ${ENV_UNDER} db..."
    echo "delete from text;" | psql -1 ${URL_UNDER}
    echo "delete from norm;" | psql -1 ${URL_UNDER}

    echo "restoring ${ENV} db into ${ENV_UNDER} db..."
    psql -1 ${URL_UNDER} < ./dumps/${ENV}/${TIMESTAMP}.sql

}

backup test
