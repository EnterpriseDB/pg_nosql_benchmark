#!/bin/bash

################################################################################
# Copyright EnterpriseDB Cooperation
# All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in
#      the documentation and/or other materials provided with the
#      distribution.
#    * Neither the name of PostgreSQL nor the names of its contributors
#      may be used to endorse or promote products derived from this
#      software without specific prior written permission.
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
#  Author: Vibhor Kumar
#  E-mail ID: vibhor.aim@gmail.com

################################################################################
# source common lib
################################################################################
source $DIRECTORY/lib/common_func_lib.sh

################################################################################
# function: pg_json_insert_maker
################################################################################
function pg_json_insert_maker ()
{
   typeset -r COLLECTION_NAME="$1"
   typeset -r NO_OF_ROWS="$2"
   typeset -r JSON_FILENAME="$3"

   plog "preparing postgresql INSERTs."
   rm -rf ${JSON_FILENAME}
   NO_OF_LOOPS=$((${NO_OF_ROWS}/11 + 1 ))
   for ((i=0;i<${NO_OF_LOOPS};i++))
   do
       json_seed_data $i | \
        sed "s/^/INSERT INTO ${COLLECTION_NAME} VALUES(\$JSON\$/"| \
        sed "s/$/\$JSON\$);/" >>${JSON_FILENAME}
   done
}

################################################################################
# run_sql_file: send SQL from a file to database
################################################################################
function run_sql_file ()
{
   typeset -r F_PGHOST="$1"
   typeset -r F_PGPORT="$2"
   typeset -r F_DBNAME="$3"
   typeset -r F_PGUSER="$4"
   typeset -r F_PGPASSWORD="$5"
   typeset -r F_SQLFILE="$6"

   export PGPASSWORD="${F_PGPASSWORD}"
   ${PGHOME}/bin/psql -qAt -h ${F_PGHOST} -p ${F_PGPORT} -U ${F_PGUSER} \
                  --single-transaction -d ${F_DBNAME} -f "${F_SQLFILE}"
}

################################################################################
# run_sql: send SQL to database
################################################################################
function run_sql ()
{
   typeset -r F_PGHOST="$1"
   typeset -r F_PGPORT="$2"
   typeset -r F_DBNAME="$3"
   typeset -r F_PGUSER="$4"
   typeset -r F_PGPASSWORD="$5"
   typeset -r F_SQL="$6"

   export PGPASSWORD="${F_PGPASSWORD}"
   ${PGHOME}/bin/psql -qAt -h ${F_PGHOST} -p ${F_PGPORT} -U ${F_PGUSER} \
                     -d ${F_DBNAME} -c "${F_SQL}"
}

################################################################################
# function: remove_pgdb (remove postgresql database)
################################################################################
function remove_pg_db ()
{
   typeset -r F_PGHOST="$1"
   typeset -r F_PGPORT="$2"
   typeset -r F_DBNAME="$3"
   typeset -r F_PGUSER="$4"
   typeset -r F_PGPASSWORD="$5"
   typeset -r F_SQL="DROP DATABASE IF EXISTS ${F_DBNAME};"

   plog "droping database ${F_DBNAME} if exists."
   run_sql "${F_PGHOST}" "${F_PGPORT}" "postgres" "${F_PGUSER}" \
           "${F_PGPASSWORD}" "${F_SQL}" 2>/dev/null >/dev/null
}

################################################################################
# function: create_pgdb (create postgresql database)
################################################################################
function create_pg_db ()
{
   typeset -r F_PGHOST="$1"
   typeset -r F_PGPORT="$2"
   typeset -r F_DBNAME="$3"
   typeset -r F_PGUSER="$4"
   typeset -r F_PGPASSWORD="$5"
   typeset -r F_SQL="CREATE DATABASE ${F_DBNAME};"

   plog "creating database ${F_DBNAME}."
   run_sql "${F_PGHOST}" "${F_PGPORT}" "postgres" "${F_PGUSER}" \
           "${F_PGPASSWORD}" "${F_SQL}"
}

################################################################################
# function: relation_size (calculate postgresql relation size)
################################################################################
function pg_relation_size ()
{
   typeset -r F_PGHOST="$1"
   typeset -r F_PGPORT="$2"
   typeset -r F_DBNAME="$3"
   typeset -r F_PGUSER="$4"
   typeset -r F_PGPASSWORD="$5"
   typeset -r F_RELATION="$6"
   typeset -r F_SQL="SELECT pg_catalog.pg_relation_size('${F_RELATION}');"

   plog "calculating PostgreSQL collection size."
   run_sql "${F_PGHOST}" "${F_PGPORT}" "${F_DBNAME}" "${F_PGUSER}" \
           "${F_PGPASSWORD}" "${F_SQL}"
}

################################################################################
# function: check if database exists
################################################################################
function if_dbexists ()
{
   typeset -r F_PGHOST="$1"
   typeset -r F_PGPORT="$2"
   typeset -r F_DBNAME="$3"
   typeset -r F_PGUSER="$4"
   typeset -r F_PGPASSWORD="$5"
   typeset -r F_SQL="SELECT COUNT(1)
                     FROM pg_catalog.pg_database
                        WHERE datname='${F_DBNAME}';"

   output=$(run_sql "${F_PGHOST}" "${F_PGPORT}" "postgres" "${F_PGUSER}" \
                    "${F_PGPASSWORD}" \
                    "${F_SQL}")
   echo ${output}
}

################################################################################
# function: mk_pgjson_collection create json table in PG
################################################################################
function mk_pg_json_collection ()
{
   typeset -r F_PGHOST="$1"
   typeset -r F_PGPORT="$2"
   typeset -r F_DBNAME="$3"
   typeset -r F_PGUSER="$4"
   typeset -r F_PGPASSWORD="$5"
   typeset -r F_TABLE="$6"
   typeset -r F_SQL1="DROP TABLE IF EXISTS ${F_TABLE} CASCADE;"
   typeset -r F_SQL2="CREATE TABLE  ${F_TABLE} (data JSONB);"

  plog "creating ${F_TABLE} collection in postgreSQL."
  run_sql "${F_PGHOST}" "${F_PGPORT}" "${F_DBNAME}" "${F_PGUSER}" \
          "${F_PGPASSWORD}" "${F_SQL1}" \
          >/dev/null 2>/dev/null
  run_sql "${F_PGHOST}" "${F_PGPORT}" "${F_DBNAME}" "${F_PGUSER}" \
          "${F_PGPASSWORD}" "${F_SQL2}" \
          >/dev/null 2>/dev/null

}

################################################################################
# function: pg_create_index create json table in PG
################################################################################
function pg_create_index_collection ()
{
   typeset -r F_PGHOST="$1"
   typeset -r F_PGPORT="$2"
   typeset -r F_DBNAME="$3"
   typeset -r F_PGUSER="$4"
   typeset -r F_PGPASSWORD="$5"
   typeset -r F_TABLE="$6"
   typeset -r F_SQL="CREATE INDEX ${F_TABLE}_idx ON ${F_TABLE} USING gin(data);"

   plog "creating index on postgreSQL collections."
   run_sql "${F_PGHOST}" "${F_PGPORT}" "${F_DBNAME}" "${F_PGUSER}" \
           "${F_PGPASSWORD}" "${F_SQL}" \
            >/dev/null

}

################################################################################
# function: delete_json_data delete json data in PG
################################################################################
function delete_json_data ()
{

   typeset -r F_PGHOST="$1"
   typeset -r F_PGPORT="$2"
   typeset -r F_DBNAME="$3"
   typeset -r F_PGUSER="$4"
   typeset -r F_PGPASSWORD="$5"
   typeset -r F_COLLECTION="$6"

   plog "droping json object in postgresql."
   run_sql "${F_PGHOST}" "${F_PGPORT}" "${F_DBNAME}" "${F_PGUSER}" \
           "${F_PGPASSWORD}" \
           "TRUNCATE TABLE ${F_COLLECTION};" >/dev/null
}

################################################################################
# function: pg_copy_benchmark
################################################################################
function pg_copy_benchmark ()
{
   typeset -r F_PGHOST="$1"
   typeset -r F_PGPORT="$2"
   typeset -r F_DBNAME="$3"
   typeset -r F_PGUSER="$4"
   typeset -r F_PGPASSWORD="$5"
   typeset -r F_COLLECTION="$6"
   typeset -r F_JSONFILE="$7"
   typeset -r F_COPY="COPY ${F_COLLECTION} FROM STDIN;"

   DBEXISTS=$(if_dbexists "${F_PGHOST}" "${F_PGPORT}" "${F_DBNAME}" \
                          "${F_PGUSER}" "${F_PGPASSWORD}")
   plog "loading data in postgresql using ${F_JSONFILE}."
   start_time=$(get_timestamp_nano)
   cat ${F_JSONFILE}|run_sql "${F_PGHOST}" "${F_PGPORT}" "${F_DBNAME}" \
                             "${F_PGUSER}" "${F_PGPASSWORD}" "${F_COPY}"
   end_time=$(get_timestamp_nano)
   total_time="$(get_timestamp_diff_nano "${end_time}" "${start_time}")"

   echo "${total_time}"

}


################################################################################
# function: benchmark postgresql inserts
################################################################################
function pg_inserts_benchmark ()
{

   typeset -r F_PGHOST="$1"
   typeset -r F_PGPORT="$2"
   typeset -r F_DBNAME="$3"
   typeset -r F_PGUSER="$4"
   typeset -r F_PGPASSWORD="$5"
   typeset -r F_COLLECTION="$6"
   typeset -r F_INSERTS="$7"

   plog "inserting data in postgresql using ${F_INSERTS}."
   start_time=$(get_timestamp_nano)
   run_sql_file "${F_PGHOST}" "${F_PGPORT}" "${F_DBNAME}" "${F_PGUSER}" \
                "${F_PGPASSWORD}" "${F_INSERTS}"
   end_time=$(get_timestamp_nano)
   total_time="$(get_timestamp_diff_nano "${end_time}" "${start_time}")"

   echo "${total_time}"
}

################################################################################
# function: benchmark postgresql select
################################################################################
function pg_select_benchmark ()
{
   typeset -r F_PGHOST="$1"
   typeset -r F_PGPORT="$2"
   typeset -r F_DBNAME="$3"
   typeset -r F_PGUSER="$4"
   typeset -r F_PGPASSWORD="$5"
   typeset -r F_COLLECTION="$6"
   typeset -r F_SELECT1="SELECT data
                         FROM ${F_COLLECTION}
                           WHERE  (data->>'brand') = 'ACME';"
   typeset -r F_SELECT2="SELECT data
                         FROM ${F_COLLECTION}
                           WHERE  (data->>'name') = 'Phone Service Basic Plan';"
   typeset -r F_SELECT3="SELECT data
                         FROM ${F_COLLECTION}
                          WHERE  (data->>'name') = 'AC3 Case Red';"
   typeset -r F_SELECT4="SELECT data
                          FROM ${F_COLLECTION}
                            WHERE  (data->>'type') = 'service';"
   local START end_time

   plog "testing FIRST SELECT in postgresql."
   start_time=$(get_timestamp_nano)
   run_sql "${F_PGHOST}" "${F_PGPORT}" "${F_DBNAME}" "${F_PGUSER}" \
           "${F_PGPASSWORD}" \
           "${F_SELECT1}" >/dev/null || exit_error "failed to execute SELECT 1."
   end_time=$(get_timestamp_nano)
   total_time1="$(get_timestamp_diff_nano "${end_time}" "${start_time}")"

   plog "testing SECOND SELECT in postgresql."
   start_time=$(get_timestamp_nano)
   run_sql "${F_PGHOST}" "${F_PGPORT}" "${F_DBNAME}" "${F_PGUSER}" \
           "${F_PGPASSWORD}" \
           "${F_SELECT2}" >/dev/null || exit_error "failed to execute SELECT 2."
   end_time=$(get_timestamp_nano)
   total_time2="$(get_timestamp_diff_nano "${end_time}" "${start_time}")"

   plog "testing THIRD SELECT in postgresql."
   start_time=$(get_timestamp_nano)
   run_sql "${F_PGHOST}" "${F_PGPORT}" "${F_DBNAME}" "${F_PGUSER}" \
           "${F_PGPASSWORD}" \
           "${F_SELECT3}" >/dev/null || exit_error "failed to execute SELECT 3."
   end_time=$(get_timestamp_nano)
   total_time3="$(get_timestamp_diff_nano "${end_time}" "${start_time}")"

   plog "testing FOURTH SELECT in postgresql."
   start_time=$(get_timestamp_nano)
   run_sql "${F_PGHOST}" "${F_PGPORT}" "${F_DBNAME}" "${F_PGUSER}" \
           "${F_PGPASSWORD}" \
           "${F_SELECT4}" >/dev/null || exit_error "failed to execute SELECT 4."
   end_time=$(get_timestamp_nano)
   total_time4="$(get_timestamp_diff_nano "${end_time}" "${start_time}")"

   AVG=$(( ($total_time1 + $total_time2 + $total_time3 + $total_time4 )/4 ))

   echo "${AVG}"
}

################################################################################
# function: mk_pgjson_collection create json table in PG
################################################################################
function analyze_collections ()
{
   typeset -r F_PGHOST="$1"
   typeset -r F_PGPORT="$2"
   typeset -r F_DBNAME="$3"
   typeset -r F_PGUSER="$4"
   typeset -r F_PGPASSWORD="$5"
   typeset -r F_TABLE="$6"
   typeset -r F_SQL="VACUUM FREEZE ANALYZE ${F_TABLE};"

   plog "performing analyze in postgreSQL."
   run_sql "${F_PGHOST}" "${F_PGPORT}" "${F_DBNAME}" "${F_PGUSER}" \
           "${F_PGPASSWORD}" "${F_SQL}" \
            >/dev/null 2>/dev/null
}

################################################################################
# function: mk_pgjson_collection create json table in PG
################################################################################
function pg_version ()
{
   typeset -r F_PGHOST="$1"
   typeset -r F_PGPORT="$2"
   typeset -r F_DBNAME="$3"
   typeset -r F_PGUSER="$4"
   typeset -r F_PGPASSWORD="$5"
   typeset -r F_SQL="select split_part(version(),' ',2);"

   version=$(run_sql "${F_PGHOST}" "${F_PGPORT}" "${F_DBNAME}" "${F_PGUSER}" \
           "${F_PGPASSWORD}" "${F_SQL}")
    echo "${version}"
}
