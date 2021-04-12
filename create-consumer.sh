#!/bin/bash

usage() {
    echo "--- Kong Conumser Creation Script ---"
    echo "Required arguments:"
    printf "\t -u username\n"
    printf "\t -i id\n"
    echo "Optional arguments:"
    printf "\t -h\n"
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

[[ -z "$USERNAME" || -z "$CUSTOMID" ]] && usage

echo "Creating Consumer..."
curl -X POST http://localhost:8081/consumers/ \
    --data "username=$USERNAME" \
    --data "custom_id=$CUSTOMID"

echo "Generating Credentials..."
curl -X POST http://localhost:8081/consumers/$USERNAME/oauth2 \
    --data "name=oauth2"
