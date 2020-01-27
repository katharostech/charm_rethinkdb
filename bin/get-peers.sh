#/bin/bash

set -e

# Get the configured cluster port
cluster_port=$(lucky get-config cluster-port)

peers=""
# For each related application
for relation_id in $(lucky relation list-ids --relation-name cluster-peers); do
    # For every unit of that application
    for related_unit in $(lucky relation list-units -r $relation_id); do
        # Get the unit's private address
        addr=$(lucky relation get -r $relation_id -u $related_unit private-address)
        
        peers="$peers $addr:$cluster_port"
    done
done

echo $peers