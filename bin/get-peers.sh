#/bin/bash
set -e

# Make sure context parameter was given
if [ -z "${1}" ]; then
    echo "Usage: ${0} CONTEXT{ cluster | driver }"
    echo "Either 'cluster' or 'driver' context argument must be provided"
    exit 1
fi 

# Get the configured port
if [ "${1}" == "cluster" ]; then
    port=$(lucky get-config cluster-port)
elif [ "${1}" == "driver" ]; then
    port=$(lucky get-config driver-port)
else
    echo "Invalid CONTEXT argument provided"
    echo "Please provide either 'cluster' or 'driver'"
    echo "Usage: ${0} CONTEXT{ cluster | driver }"
    echo "Example: ${0} cluster"
fi

peers=""
# For each related application
for relation_id in $(lucky relation list-ids --relation-name cluster-peers); do
    # For every unit of that application
    for related_unit in $(lucky relation list-units -r $relation_id); do
        # Get the unit's private address
        addr=$(lucky relation get -r $relation_id -u $related_unit private-address)
        
        peers="$peers $addr:$port"
    done
done

echo $peers
