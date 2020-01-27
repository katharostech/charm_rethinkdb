#!/bin/bash

# Exit immediately on failure
set -ex

# All of these settings are app-wide an can only be set by leader.
# Exit early if not the leader
if [ ! "$(lucky leader is-leader)" = "true" ]; then
    exit 0
    lucky set-status active
fi

# Add peer addresses
servers=$(./bin/get-peers.sh)
# Add our own address
servers="$servers $(lucky private-address):$(lucky get-config cluster-port)"
# Get password
password=$(lucky leader get admin_password)
# Get user ( hardcoded for now )
user="admin"


# If some hook that will change configuration or peers has run
if [ "$1" = "update-config" ]; then
    # Update all relations' config
    for relation_id in $(lucky relation list-ids --relation-name reql); do
        # Update relation config
        lucky relation set --app -r $relation_id \
            "servers=$servers" \
            "user=$user" \
            "password=$password"
    done

# If this is being run as the reql-relation-changed-hook
elif [ "$LUCKY_HOOK" = "reql-relation-changed" ]; then
    # Set config for updated the relation
    lucky relation set --app \
        "servers=$servers" \
        "user=$user" \
        "password=$password"

fi