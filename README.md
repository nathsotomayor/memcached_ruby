# Memcached Ruby Server

This is a Memcached Ruby server (TCP/IP socket). The server listen for new connections on a TCP port, accept connections and commands from any Memcached client.

This server was develop in Ruby programming language

## About Memcached

**Free & open source, high-performance, distributed memory object caching system**, generic in nature, but intended for use in speeding up dynamic web applications by alleviating database load.

[Memcached](https://memcached.org/) is an in-memory key-value store for small chunks of arbitrary data (strings, objects) from results of database calls, API calls, or page rendering.


## Commands

Memcached handles a small number of basic commands. In this server it's implement a subset of Memcached commands, with all of their allowed options.

### Storage Commands

| Command | Function |
|---------|----------|
| set | Most common command. Store this data, possibly overwriting any existing data |
| add | Store this data, only if it does not already exist |
| append | Add this data after the last byte in an existing item |
| prepend | Same as append, but adding new data before existing data |
| replace | Store this data, but only if the data already exists |
| cas (Check And Set or Compare And Swap) | An operation that stores data, but only if no one else has updated the data since you read it last |


### Retrieval commands:

| Command | Function |
|---------|----------|
| get | Command for retrieving data. Takes one or more keys and returns all found items |
| gets | An alternative get command for using with CAS. Returns a CAS identifier with the item |


## How to use it

### Download:

Clone the repository with the command line interface:

`git clone https://github.com/nathsotomayor/memcached_ruby.git`

### Execution:

#### Start the server

Go to the project (repository) folder and execute the command:

```bash
memcached_ruby$ ruby bin/memcached_server.rb -p 2000
Server running and listening on port 2000...
```

If you no provide the port this will be the port 2000 by default.

#### Start the client

Go to the project (repository) folder and execute the command:

```bash
memcached_ruby$ ruby bin/memcached_client.rb -p 2000
```

If you no provide the port this will be the port 2000 by default.


## Usage examples

### Storage commands
* **Set:**
 Store this data, possibly overwriting any existing data

Syntax:

```
set key flags timetolive
value
```

Example:

```
set any_key 1 100
any_value
STORED
```

* **Add:**
 Store this data, only if it does not already exist

Syntax:

```
add key flags timetolive
value
```

Example:

```
Enter a command:
add new_key 1 100
new_value
STORED

Enter a command:
add new_key 1 200
other_value
NOT_STORED
```


* **Append:**
 Add this data after the last byte in an existing item

Syntax:

```
append key flags timetolive
value
```

Example:
```bash
Enter a command:
append key 1 100
other
NOT_STORED

Enter a command:
add key 1 100
value
STORED

Enter a command:
append key 1 200
other
STORED
```

* **Prepend:**
 Same as append, but adding new data before existing data
 
Syntax:

```
prepend key flags timetolive
value
```

Example:

```
Enter a command:
prepend key 1 100
other
NOT_STORED

Enter a command:
add key 1 100
value
STORED

Enter a command:
prepend key 1 200
other
STORED
```

* **Replace:**
 Store this data, but only if the data already exists

Syntax:

```
replace key flags timetolive
value
```

Example:

```
Enter a command:
replace new_key 1 100
new_value
NOT_STORED

Enter a command:
add new_key 1 100
new_value
STORED

Enter a command:
replace new_key 1 200
other_value
STORED
```

* **Cas (Check and Set or Compare and Swap):**
 An operation that stores data, but only if no one else has updated the data since you read it last
 
Syntax:

```
cas key flags timetolive token
value
```

Example:

```
Enter a command:
cas key 1 100
value
ERROR

Enter a command:
cas key 1 100 9876
value
NOT_FOUND

Enter a command:
add key 1 100
value
STORED

Enter a command:
gets key
VALUE key 1 9876
value
END

Enter a command:
cas key 0 200 9876
othervalue
STORED
```

### Retrieval commands

* **Get:**
 Command for retrieving data. Takes one or more keys and returns all found items
Syntax

`get key`
or
`get key1 key2 ...`

Example:

```
Enter a command:
get key
NOT_FOUND

Enter a command:
add key 1 100
value
STORED

Enter a command:
get key
VALUE key 1
value
END

Enter a command:
add other_key 2 100
other_value
STORE

Enter a command:
get key other_key
VALUE key 1
value
VALUE other_key 2
other_value
END
```

* **Gets:**
 An alternative get command for using with CAS. Returns a CAS identifier with the item

Syntax:

`gets key`
or
`gets ke1 key2 ...`

Example:

```
Enter a command:
gets key
NOT_FOUND

Enter a command:
add key 1 100
value
STORED

Enter a command:
get key
VALUE key 1 9876
value
END

Enter a command:
add other_key 2 100
other_value
STORE

Enter a command:
gets key other_key
VALUE key 1 9876
value
VALUE other_key 2 6789
other_value
END
```

## Ruby unit tests
Go to the project (repository) folder and execute the command:

```bash
memcached_ruby$ ruby tests/test_name_file.rb
```

The output should look like this:

```bash
Run options: --seed 9374

# Running:

.................

Finished in 0.003744s, 4540.5982 runs/s, 5341.8802 assertions/s.
17 runs, 20 assertions, 0 failures, 0 errors, 0 skips
```

## References

Memcached: http://memcached.org/

Full list of commands: http://lzone.de/cheat-sheet/memcached

The protocol specification: https://github.com/memcached/memcached/blob/master/doc/protocol.txt
