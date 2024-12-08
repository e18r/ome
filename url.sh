#! /bin/bash

cd "$(dirname ${0})"

if [[ ("${1}" != "dev" && "${1}" != "test" && "${1}" != "prod") \
   || ("${2}" != "heroku" && "${2}" != "neon") ]]; then
    echo "usage: ./url.sh ENV TYPE"
    echo
    echo "ENV:  dev|test|prod"
    echo "TYPE: heroku|neon"
    exit 1
fi

ENV=${1}
TYPE=${2}
if [ ${ENV} = "dev" ]; then
    jq -r .${TYPE}.dev ./settings.json
elif [ ${TYPE} = "neon" ]; then
    PROJECT=$(jq -r .neon.${ENV} ./settings.json)
    neon connection-string --project-id ${PROJECT}
else
    PROJECT=$(jq -r .heroku.${ENV} ./settings.json)
    heroku pg:credentials:url -a ${PROJECT} | grep postgres | xargs
fi
