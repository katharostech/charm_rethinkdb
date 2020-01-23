#!/bin/bash

# Exit immediately upon failure
set -e

lucky set-status maintenance 'Configuring RethinkDB'

# Set container image
lucky container image set 'rethinkdb:latest'

# Add data volume
lucky container volume add data /data

# Get configuration
bind=$(lucky get-config bind)
bind_http=$(lucky get-config bind-http)
http_port=$(lucky get-config http-port)
cluster_port=$(lucky get-config cluster-port)
driver_port=$(lucky get-config driver-port)

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

# Set commandline arguments
lucky container set-entrypoint rethinkdb
lucky container set-command -C "--bind $bind --bind-http $bind_http --http-port $http_port --cluster-port $cluster_port --driver-port $driver_port"

lucky set-status active
