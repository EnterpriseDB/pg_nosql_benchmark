pg_mongo_benchmark
==================

A tool for benchmarking PostgreSQL (JSONB) and MongoDB (BSON)

Introduction
-------------

This is a benchmarking tool which user can use for benchmark  mongoDB 2.6 (BSON) and postgreSQL 9.4 (JSONB) database with json data.

This tool perform following to do the benchmarking of BSON and JSONB:
* Generates JSON rows as per value in json_rows variable in pg_mongo_benchmark.sh
* Benchmark data loading in MongoDB and PostgreSQL using mongoimport and PostgreSQL's COPY command.
* benchmarkdata loading in MongoDB and PostgreSQL using INSERT command.
* Benchmark 4 SELECT Queries in MongoDB & PostgreSQL and returns result as an average time taken by 4 SELECT queries.

Requirements
------------

* To run this tool use CentOS 6.4 or later Operating System.
* Run this script on separate CentOS server from where user has access on MongoDB and PostgreSQL Server.
* This script works with PostgreSQL 9.4 beta server and MongoDB 2.6.
* For better benchmarking, please use CentOS 64 bit machine of same size for MongoDB and PostgreSQL.
* To use this tool, set following environment Variables in pg_mongo_benchmark.sh:


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

* create Admin user in MongoDB user can use following command on MongoDB server:
```
   > db.createUser({ user: "mongo",
                     pwd: "mongo",
                     roles:[{ role: "userAdmin",
                              db: "benchmark"
                            }]
                    })
```

* To create super user in postgresql, user can use following command:
```
CREATE USER postgres PASSWORD '<password>' WITH SUPERUSER;
```

For more information on CREATE USER command in PostgreSQL, please use following link:
   http://www.postgresql.org/docs/9.4/static/sql-createuser.html

Recommended modules
--------------------
  Following packages will be needed on server for this tool:
  1. mongodb-org-2.6.3-1.x86_64
  2. postgresql94-9.4beta1-1PGDG.rhel6.x86_64
  3. bc-1.06.95-1.el6.x86_64
  4. git-1.7.1-3.el6_4.1.x86_64

Installation
------------

To install this tool on client server, you can use following command:

1. git clone https://github.com/vibhorkum/pg_mongo_benchmark.git
2. cd pg_mongo_benchmark
3. chmod +x pg_mongo_benchmark.sh

