# RethinkDB Charm

A [Juju](https://jaas.ai) charm for RethinkDB, a realtime, scalable, NoSQL database.

## Usage

This charm can be deployed like any other charm from the charm store. The config options are shown below.

This charm is fully scalable to any number of units.

### Data storage

Currently the data for the RethinkDB database will be stored at `/var/lib/lucky/unit_name_number/volumes/data`. There isn't yet an integration with Juju storage.

### The reql Relation

The reql relation currently provides the `user`, `password`, and `servers` app relations. To read these values in a charm you can use the `relation-get` hook tool like so:

    relation-get -r relation_id --app servers

Currently the `reql` interface is under development and it will eventually support connecting to the cluster as a user other than `admin` and therefore provide better support for having multiple applications connected to the RethinkDB cluster. If you do not mind all applications connecting with the `admin` account, then it is still possible to have multiple applications connected to the same RethinkDB cluster.

#### Keys

- `servers`: Servers will be the list of rethinkdb IP addresses with driver port separated by spaces. For example: `192.168.106.133:28015 192.168.106.12:28015`.
- `user`: Currently this is always `admin`.
- `password`: The password for the provided user.