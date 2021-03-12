#!/bin/bash

if [ -z $1 ]; then
    echo "Usage: $0 DB_NAME"
    exit 1
fi

db_name=$1

# Waits for the transaction db status to become "create succeeded"
wait_for_db_creation() {
    time_limit=600 # 10 minutes

    while [ $time_limit -ne 0 ] && [ -z "$service_status" ]; do
        echo "Waiting for service to become available. Seconds before timeout: $time_limit"
        sleep 30
        time_limit=$((time_limit - 30))
        service_status=$(cf service $db_name | grep "status:" | grep "create succeeded")
    done

    # If the service still isn't available, fail the script
    if [ -z "$service_status" ]; then
        echo "DB failed to become ready within the time limit."
        exit 1
    fi

    echo "DB creation finalized"
}

create_db() {
    service_plan="micro-psql"
    cf create-service aws-rds $service_plan $db_name
}

# Test if DB service exists at all
cf services | grep --silent $db_name

if [ $? -eq 1 ]; then
    echo "Unable to find database service: $db_name. Creating..."
    create_db
    wait_for_db_creation
    exit 0
else
    # The DB service existed, but the service status is not yet known
    echo "Found service $db_name. Checking service status..."

    db_status=$(cf service $db_name | grep "status:")

    db_succeeded=$(echo $db_status | grep "create succeeded")
    db_in_progress=$(echo $db_status | grep "in progress")

    if [ ! -z "$db_succeeded" ]; then
        echo "DB already available"
    elif [ ! -z "$db_in_progress" ]; then
        echo "DB creation was "in progress"."
        wait_for_db_creation
    else
        # Status was neither "in progress" or "create succeeded". There's likely
        # a problem with the DB service that can't be resolved without human interaction
        echo "Found DB service: $db_name but status was: $db_status"
        exit 1
    fi
fi
