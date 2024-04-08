#! /bin/bash

cd "$(dirname $0)"

if [ ! "$1" ]; then
    echo "usage: ./url.sh [test|prod]"
    exit 1
fi

ENV=$1
PROJECT=$(jq -r .project.$ENV ./settings.json)
heroku pg:credentials:url -a $PROJECT | tail -n1 | xargs
