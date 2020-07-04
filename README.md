# Memcached Ruby Server

This is a Memcached Ruby server (TCP/IP socket). The server listen for new connections on a TCP port, accept connections and commands from any Memcached client.

This server was develop in Ruby programming language

## About Memcached

**Free & open source, high-performance, distributed memory object caching system**, generic in nature, but intended for use in speeding up dynamic web applications by alleviating database load.

[Memcached](https://memcached.org/) is an in-memory key-value store for small chunks of arbitrary data (strings, objects) from results of database calls, API calls, or page rendering.


## Commands

### Storage Commands

| Command | Function |
----------------------
| set | Most common command. Store this data, possibly overwriting any existing data |
| add | Store this data, only if it does not already exist |
| append | Add this data after the last byte in an existing item |
| prepend | Same as append, but adding new data before existing data |
| replace | Store this data, but only if the data already exists |
| cas (Check And Set or Compare And Swap) | An operation that stores data, but only if no one else has updated the data since you read it last |


### Retrieval commands:

| Command | Function |
----------------------
| get | Command for retrieving data. Takes one or more keys and returns all found items |
| gets | An alternative get command for using with CAS. Returns a CAS identifier with the item |