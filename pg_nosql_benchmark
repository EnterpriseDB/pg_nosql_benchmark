#/bin/bash

#===============================================================================
#title           : pg_mongo_benchmark.sh.
#description     : This script will help in benchmarking PostgreSQL (JSONB) and
#                : MongoDB (BSON).
#author          : Vibhor Kumar (vibhor.aim@gmail.com).
#date            : July 17, 2014
#version         : 1.0
#usage           : bash pg_mongo_benchmark.sh
#notes           : Install Vim and Emacs to use this script.
#bash_version    : GNU bash, version 4.1.2(1)-release (x86_64-redhat-linux-gnu)
#===============================================================================

################################################################################
# set require variables.
################################################################################
DIRECTORY=$(dirname $0)
BASENAME=$(basename $0)

PGHOME="/usr/ppas-9.3"
PGHOST="172.17.0.4"
PGPORT="5432"
PGUSER="postgres"
PGPASSWORD="postgres"
PGDATABASE="benchmark"

PGBIN="/usr/ppas-9.3/bin"

################################################################################
# set mongo variables.
################################################################################
MONGO="/usr/bin/mongo"
MONGOIMPORT="/usr/bin/mongoimport"
MONGOHOST="172.17.0.3"
MONGOPORT="27017"
MONGOUSER="mongo"
MONGOPASSWORD="mongo"
MONGODBNAME="benchmark"

COLLECTION_NAME="json_tables"
SAMPLEJSON="sample.json"
PG_INSERTS="sample_pg_inserts.json"
MONGO_INSERTS="sample_mongo_inserts.json"

export PATH=$PGBIN:$PATH

################################################################################
# source library files
################################################################################
source ${DIRECTORY}/lib/pg_func_lib.sh
source ${DIRECTORY}/lib/mongo_func_lib.sh

################################################################################
# declare require arrays
################################################################################
declare -a json_rows=(10000000)

declare -a pg_size_time
declare -a pg_copy_time
declare -a pg_inserts_time
declare -a pg_select_time

# mongo specific arrays
declare -a mongo_size_time
declare -a mongo_copy_time
declare -a mongo_inserts_time
declare -a mongo_select_time

################################################################################
# main function
################################################################################
mongodb_version=$(mongo_version "${MONGOHOST}"     \
                                "${MONGOPORT}"     \
                                "${MONGODBNAME}"   \
                                "${MONGOUSER}"     \
                                "${MONGOPASSWORD}"
                  )

pg_version=$(pg_version "${PGHOST}"          \
                        "${PGPORT}"          \
                        "${PGDATABASE}"      \
                        "${PGUSER}"          \
                        "${PGPASSWORD}"
            )

process_log "MongoDB Version $mongodb_version"
process_log "PostgreSQL Version $pg_version"


for (( indx=0 ; indx < ${#json_rows[@]} ; indx++ ))
do
   generate_json_rows "${json_rows[${indx}]}" \
                      "${SAMPLEJSON}"

   pg_json_insert_maker "${COLLECTION_NAME}"    \
                        "${json_rows[${indx}]}" \
                        "${PG_INSERTS}"

   mongo_json_insert_maker "${COLLECTION_NAME}"    \
                           "${json_rows[${indx}]}" \
                           "${MONGO_INSERTS}"


   remove_pg_db "${PGHOST}"     \
                "${PGPORT}"     \
                "${PGDATABASE}" \
                "${PGUSER}"     \
                "${PGPASSWORD}"
   create_pg_db "${PGHOST}"     \
                "${PGPORT}"     \
                "${PGDATABASE}" \
                "${PGUSER}"     \
                "${PGPASSWORD}"

   drop_mongocollection "${MONGOHOST}"     \
                        "${MONGOPORT}"     \
                        "${MONGODBNAME}"   \
                        "${MONGOUSER}"     \
                        "${MONGOPASSWORD}" \
                        "${COLLECTION_NAME}"

   mk_pg_json_collection "${PGHOST}"     \
                         "${PGPORT}"     \
                         "${PGDATABASE}" \
                         "${PGUSER}"     \
                         "${PGPASSWORD}" \
                         "${COLLECTION_NAME}"

   pg_copy_time[${indx}]=$(pg_copy_benchmark  "${PGHOST}"          \
                                              "${PGPORT}"          \
                                              "${PGDATABASE}"      \
                                              "${PGUSER}"          \
                                              "${PGPASSWORD}"      \
                                              "${COLLECTION_NAME}" \
                                              "${SAMPLEJSON}"
                          )

   delete_json_data "${PGHOST}"      \
                    "${PGPORT}"      \
                    "${PGDATABASE}"  \
                    "${PGUSER}"      \
                    "${PGPASSWORD}"  \
                    "${COLLECTION_NAME}"

   pg_inserts_time[${indx}]=$(pg_inserts_benchmark  "${PGHOST}"          \
                                                    "${PGPORT}"          \
                                                    "${PGDATABASE}"      \
                                                    "${PGUSER}"          \
                                                    "${PGPASSWORD}"      \
                                                    "${COLLECTION_NAME}" \
                                                    "${PG_INSERTS}"
                              )

   pg_create_index_collection "${PGHOST}"     \
                              "${PGPORT}"     \
                              "${PGDATABASE}" \
                              "${PGUSER}"     \
                              "${PGPASSWORD}" \
                              "${COLLECTION_NAME}"

   mongo_copy_time[${indx}]=$(mongodb_import_benchmark "${MONGOHOST}"       \
                                                       "${MONGOPORT}"       \
                                                       "${MONGODBNAME}"     \
                                                       "${MONGOUSER}"       \
                                                       "${MONGOPASSWORD}"   \
                                                       "${COLLECTION_NAME}" \
                                                       "${SAMPLEJSON}"
                              )

   drop_mongocollection "${MONGOHOST}"     \
                        "${MONGOPORT}"     \
                        "${MONGODBNAME}"   \
                        "${MONGOUSER}"     \
                        "${MONGOPASSWORD}" \
                        "${COLLECTION_NAME}"

   mongo_inserts_time[${indx}]=$(mongodb_inserts_benchmark "${MONGOHOST}"       \
                                                           "${MONGOPORT}"       \
                                                           "${MONGODBNAME}"     \
                                                           "${MONGOUSER}"       \
                                                           "${MONGOPASSWORD}"   \
                                                           "${COLLECTION_NAME}" \
                                                            "${MONGO_INSERTS}"
                                )

   mongodb_create_index "${MONGOHOST}"     \
                        "${MONGOPORT}"     \
                        "${MONGODBNAME}"   \
                        "${MONGOUSER}"     \
                        "${MONGOPASSWORD}" \
                        "${COLLECTION_NAME}"

   pg_select_time[${indx}]=$(pg_select_benchmark "${PGHOST}"     \
                                                 "${PGPORT}"     \
                                                 "${PGDATABASE}" \
                                                 "${PGUSER}"     \
                                                 "${PGPASSWORD}" \
                                                 "${COLLECTION_NAME}"
                            )
   pg_size_time[${indx}]=$(pg_relation_size "${PGHOST}"     \
                                            "${PGPORT}"     \
                                            "${PGDATABASE}" \
                                            "${PGUSER}"     \
                                            "${PGPASSWORD}" \
                                            "${COLLECTION_NAME}"
                          )

   mongo_select_time[${indx}]=$(mongodb_select_benchmark "${MONGOHOST}"     \
                                                         "${MONGOPORT}"     \
                                                         "${MONGODBNAME}"   \
                                                         "${MONGOUSER}"     \
                                                         "${MONGOPASSWORD}" \
                                                         "${COLLECTION_NAME}"
                                )

   mongo_size_time[${indx}]=$(mongo_collection_size "${MONGOHOST}"     \
                                                    "${MONGOPORT}"     \
                                                    "${MONGODBNAME}"   \
                                                    "${MONGOUSER}"     \
                                                    "${MONGOPASSWORD}" \
                                                    "${COLLECTION_NAME}"
                             )
done

print_result "number of rows"     "${json_rows[@]}"
print_result "PG COPY (ns)"       "${pg_copy_time[@]}"
print_result "PG INSERT (ns)"     "${pg_inserts_time[@]}"
print_result "PG SELECT (ns)"     "${pg_select_time[@]}"
print_result "PG SIZE (bytes)"    "${pg_size_time[@]}"
print_result "MONGO IMPORT (ns)"  "${mongo_copy_time[@]}"
print_result "MONGO INSERT (ns)"  "${mongo_inserts_time[@]}"
print_result "MONGO SELECT (ns)"  "${mongo_select_time[@]}"
print_result "MONGO SIZE (bytes)" "${mongo_size_time[@]}"

rm -rf ${SAMPLEJSON}*
rm -rf ${PG_INSERTS}
rm -rf ${MONGO_INSERTS}
