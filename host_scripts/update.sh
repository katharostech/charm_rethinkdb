#!/bin/bash

# Exit immediately upon failure
set -ex

# Exit early if we are not ready to start yet
if [ "$(lucky kv get start_server)" != "true" ]; then
    exit 0
fi

# Get configuration
bind=$(lucky get-config bind)
bind_http=$(lucky get-config bind-http)
http_port=$(lucky get-config http-port)
cluster_port=$(lucky get-config cluster-port)
driver_port=$(lucky get-config driver-port)
private_address=$(lucy private-address)

# Collect peers
peers=""
for relation_id in $(lucky relation list-ids --relation-name cluster-peers); do
    for related_unit in $(lucky relation list-units -r $relation_id); do
        addr=$(lucky relation get -r $relation_id -u $related_unit private-address)
        
        peers="$peers $addr:$cluster_port"
    done
done

# If we are not the leader and we don't have any peers then don't start server
if [ "$peers" = "" -a "$(lucky leader is-leader)" = "false" ]; then
    exit 0
fi

# Initial password "auto" will work for joining to an existing cluster
initial_password="auto"

# If we are the leader
if [ "$(lucky leader is-leader)" = "true" ]; then

    # If admin password is not set
    if [ "$(lucky leader get admin_password)" = "" ]; then
        # Generate admin password
        initial_password=$(lucky random --length 32)

        # Set the admin password
        lucky leader set "admin_password=$initial_password"
    fi
fi

# Configure RethinkDB
lucky set-status maintenance 'Configuring RethinkDB'

# Set container image
lucky container image set 'rethinkdb:latest'

# Add data volume
lucky container volume add data /data

# Remove previously opened ports
lucky port close --all
lucky container port remove --all

# Add port bindings for provided ports
lucky port open $http_port
lucky container port add "$http_port:$http_port"
lucky port open $cluster_port
lucky container port add "$cluster_port:$cluster_port"
lucky port open $driver_port
lucky container port add "$driver_port:$driver_port"

# Add join argument for each peer
join_args=""
for peer in $peers; do
    join_args="$join_args -j $peer"
done

# Set commandline arguments
lucky container set-entrypoint rethinkdb
lucky container set-command -- \
    --bind $bind \
    --bind-http $bind_http \
    --http-port $http_port \
    --cluster-port $cluster_port \
    --driver-port $driver_port \
    --canonical-address $private_address \
    --bind-cluster $private_address \
    --initial-password $initial_password \
    $join_args

lucky set-status active
