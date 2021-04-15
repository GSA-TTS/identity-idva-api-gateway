#!/bin/bash

usage() {
    echo "Usage: $0 -u <username> -i <id> [-h]"
    exit 1
}

while getopts hu:i: arg; do
    case $arg in
        h) usage ;;
        u) USERNAME=${OPTARG} ;;
        i) CUSTOMID=${OPTARG} ;;
        *) usage ;;
    esac
done

if [[ -z "$USERNAME" || -z "$CUSTOMID" ]]
then
    usage
fi

echo "Creating Consumer..."
curl -X POST http://localhost:8081/consumers/ \
    --data "username=$USERNAME" \
    --data "custom_id=$CUSTOMID"

echo "Generating Credentials..."
curl -X POST http://localhost:8081/consumers/"$USERNAME"/oauth2 \
    --data "name=oauth2"
