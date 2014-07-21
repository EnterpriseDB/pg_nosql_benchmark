pg_nosql_benchmark
==================

This is tool for benchmarking Postgres (JSONB) and MongoDB (BSON)

Introduction
-------------

This is a benchmarking tool developed by EnterpriseDB to benchmark  MongoDB 2.6 (BSON) and Postgres 9.4 (JSONB) database using JSON data. The current version focuses on data ingestion and simple select operations in single-instance environments - later versions will include a complete range of workloads (including deleting, updating, appending, and complex select operations) and they will also evaluate multi-server configurations.

This tool performs the following tasks to compare of MongoDB and PostgreSQL:
* The tool generates a large set of JSON documents (the number of documents is defined by the value of the variable json_rows in pg_mongo_benchmark.sh)
* The data set is loaded into MongoDB and PostgreSQL using mongoimport and PostgreSQL's COPY command.
* The same data is loaded into MongoDB and PostgreSQL using the INSERT command.
* The tool executes 4 SELECT Queries in MongoDB & PostgreSQL.

Requirements
------------

* pg_nosql_benchmark uses CentOS 6.4 or later, and is designed for PostgreSQL 9.4 beta server and MongoDB 2.6.
* The configuration requires three servers
	* Load generating server
	* MongoDB server
	* PostgreSQL server
* The MongoDB server and the PostgreSQL server should be configured identically	
* The script is designed to run from the central load-generating server, which must have access to the MongoDB and PostgreSQL servers.
* The following environment variables in pg_nosql_benchmark control the execution:

  PostgreSQL Variables:
```   
   PGHOME=/usr/pgsql-9.4    # Installation location of PostgreSQL binaries.
   PGHOST="172.17.0.2"      # Hostname/IP address of PostgreSQL
   PGPORT="5432"            # Port number on which PostgreSQL is running.
   PGUSER="postgres"        # PostgreSQL database username.
   PGPASSWORD="postgres"    # PostgreSQL database users password.
   PGBIN=/usr/pgsql-9.4/bin # PostgreSQL binary location.
```

  MongoDB Variables:

```
   MONGO="/usr/bin/mongo"             # Complete path of mongo Command binary
   MONGOIMPORT="/usr/bin/mongoimport" # complete path of mongoimport binary
   MONGOHOST="172.17.0.3"             # Hostname/IP address of MongoDB
   MONGOPORT="27017"                  # Port number on which MongoDB is running.
   MONGOUSER="mongo"                  # Mongo database username
   MONGOPASSWORD="mongo"              # MongoDB database username's password
   MONGODBNAME="benchmark"            # mongoDB database name.
```

* To create the admin user in MongoDB use the following command on the MongoDB server:
```
   > db.createUser({ user: "mongo",
                     pwd: "mongo",
                     roles:[{ role: "userAdmin",
                              db: "benchmark"
                            }]
                    })
```

* To create the super user in PostgreSQL use the following command:
```
CREATE USER postgres PASSWORD '<password>' WITH SUPERUSER;
```

For more information on CREATE USER command in PostgreSQL, please check:
   http://www.postgresql.org/docs/9.4/static/sql-createuser.html

Recommended modules
--------------------
  The following packages are needed to run the benchmark tool:
  1. mongodb-org-2.6.3-1.x86_64
  2. postgresql94-9.4beta1-1PGDG.rhel6.x86_64
  3. bc-1.06.95-1.el6.x86_64
  4. git-1.7.1-3.el6_4.1.x86_64

Installation
------------

To install this tool on the load generating server, use the following command:

1. git clone https://github.com/vibhorkum/pg_mongo_benchmark.git
2. cd pg_mongo_benchmark
3. chmod +x pg_nosql_benchmark

