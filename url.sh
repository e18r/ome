#! /bin/bash

cd "$(dirname $0)"

if [ "$1" != "dev" -a "$1" != "test" -a "$1" != "prod" ]; then
    echo "usage: ./url.sh [dev|test|prod]"
    exit 1
fi

ENV=$1
if [ $ENV = "dev" ]; then
    echo "palindr"
elif [ $ENV = "test" ]; then
    PROJECT=$(jq -r .neon.$ENV ./settings.json)
    neon connection-string --project-id $PROJECT
else
    PROJECT=$(jq -r .project.$ENV ./settings.json)
    heroku pg:credentials:url -a $PROJECT | grep postgres | xargs
fi
