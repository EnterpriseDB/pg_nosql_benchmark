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
DIRECTORY=$(dirname $0)
source ${DIRECTORY}/lib/common_func_lib.sh

################################################################################
# mongo_run_command: send command to mongodb
################################################################################
function run_mongo_command ()
{
   typeset -r F_MONGOHOST="$1"
   typeset -r F_MONGOPORT="$2"
   typeset -r F_MONGODBNAME="$3"
   typeset -r F_MONGOUSER="$4"
   typeset -r F_MONGOPASSWORD="$5"
   typeset -r F_MONGOCOMMAND="$6"

   ${MONGO} ${F_MONGOHOST}:${F_MONGOPORT}/${F_MONGODBNAME} \
           --username ${F_MONGOUSER}                       \
           --password ${F_MONGOPASSWORD} --quiet --eval "${F_MONGOCOMMAND}"
}

################################################################################
# run_mong_file: execute list of commands on mongo
################################################################################
function run_mongo_file ()
{
   typeset -r F_MONGOHOST="$1"
   typeset -r F_MONGOPORT="$2"
   typeset -r F_MONGODBNAME="$3"
   typeset -r F_MONGOUSER="$4"
   typeset -r F_MONGOPASSWORD="$5"
   typeset -r F_COMMANDFILE="$6"

   ${MONGO} ${F_MONGOHOST}:${F_MONGOPORT}/${F_MONGODBNAME} \
           --username ${F_MONGOUSER}                       \
           --password ${F_MONGOPASSWORD} --quiet < ${F_COMMANDFILE}
}

################################################################################
# function: drop_mongocollection drop specific collection in mongo
################################################################################
function drop_mongocollection ()
{
   typeset -r F_MONGOHOST="$1"
   typeset -r F_MONGOPORT="$2"
   typeset -r F_MONGODBNAME="$3"
   typeset -r F_MONGOUSER="$4"
   typeset -r F_MONGOPASSWORD="$5"
   typeset -r F_MONGOCOLLECTION="$6"
   typeset -r F_MONGOCOMMAND="printjson(db.${F_MONGOCOLLECTION}.drop())"

   process_log "dropping mongo collection ${F_MONGOCOLLECTION}"
   run_mongo_command "${F_MONGOHOST}" "${F_MONGOPORT}" "${F_MONGODBNAME}" \
         "${F_MONGOUSER}" "${F_MONGOPASSWORD}" "${F_MONGOCOMMAND}" >/dev/null

}

################################################################################
# function: mongo_insert_maker
################################################################################
function mongo_json_insert_maker ()
{
   typeset -r COLLECTION_NAME="$1"
   typeset -r NO_OF_ROWS="$2"
   typeset -r JSON_FILENAME="$3"

   rm -rf ${JSON_FILENAME}
   process_log "preparing mongo insert commands."
   NO_OF_LOOPS=$((${NO_OF_ROWS}/11 + 1 ))
   for ((i=0;i<${NO_OF_LOOPS};i++))
   do
       json_seed_data $i | sed "s/^/db.${COLLECTION_NAME}.insert( /" | \
                         sed "s/$/ )/" >>${JSON_FILENAME}
   done
}

################################################################################
# function: benchmark mongo-import
################################################################################
function mongodb_import_benchmark ()
{

   typeset -r F_MONGOHOST="$1"
   typeset -r F_MONGOPORT="$2"
   typeset -r F_MONGODBNAME="$3"
   typeset -r F_MONGOUSER="$4"
   typeset -r F_MONGOPASSWORD="$5"
   typeset -r F_COLLECTION="$6"
   typeset -r F_FILENAME="$7"

   process_log "testing mongoimport."
   start_time=$(get_timestamp_nano)
   ${MONGOIMPORT} --host ${F_MONGOHOST} --db ${F_MONGODBNAME}             \
                  --username ${F_MONGOUSER} --password ${F_MONGOPASSWORD} \
                  --type json  --port ${F_MONGOPORT}                      \
                  --collection ${F_COLLECTION} < ${F_FILENAME} >/dev/null \
                  2>>/dev/null
   end_time=$(get_timestamp_nano)
   total_time="$(get_timestamp_diff_nano "${end_time}" "${start_time}")"
   echo "${total_time}"
}

################################################################################
# function: benchmark mongo inserts
################################################################################
function mongodb_inserts_benchmark ()
{

   typeset -r F_MONGOHOST="$1"
   typeset -r F_MONGOPORT="$2"
   typeset -r F_MONGODBNAME="$3"
   typeset -r F_MONGOUSER="$4"
   typeset -r F_MONGOPASSWORD="$5"
   typeset -r F_COLLECTION="$6"
   typeset -r F_JSONINSERTS="$7"

   process_log "testing inserts in mongo"
   start_time=$(get_timestamp_nano)
   run_mongo_file "${F_MONGOHOST}" "${MONGOPORT}" "${F_MONGODBNAME}" \
                  "${F_MONGOUSER}" "${F_MONGOPASSWORD}" \
                  "${F_JSONINSERTS}" >/dev/null
   end_time=$(get_timestamp_nano)
   total_time="$(get_timestamp_diff_nano "${end_time}" "${start_time}")"

   echo "${total_time}"
}

################################################################################
# function: benchmark mongo-select
################################################################################
function mongodb_select_benchmark ()
{

   F_MONGOHOST="$1"
   F_MONGOPORT="$2"
   F_MONGODBNAME="$3"
   F_MONGOUSER="$4"
   F_MONGOPASSWORD="$5"
   F_COLLECTION="$6"
   F_MONGOSELECT1="db.${F_COLLECTION}.find({ brand: 'ACME'})"
   F_MONGOSELECT2="db.${F_COLLECTION}.find({ name: 'Phone Service Basic Plan'})"
   F_MONGOSELECT3="db.${F_COLLECTION}.find({ name: 'AC3 Case Red'})"
   F_MONGOSELECT4="db.${F_COLLECTION}.find({ type: 'service'})"

   process_log "testing mongo FIRST SELECT."
   start_time=$(get_timestamp_nano)
   run_mongo_command "${F_MONGOHOST}" "${MONGOPORT}" "${F_MONGODBNAME}" \
                     "${F_MONGOUSER}" \
                     "${F_MONGOPASSWORD}" "${F_MONGOSELECT1}" >/dev/null
   end_time=$(get_timestamp_nano)
   total_time1="$(get_timestamp_diff_nano "${end_time}" "${start_time}")"

   process_log "testing mongo SECOND SELECT."
   start_time=$(get_timestamp_nano)
   run_mongo_command "${F_MONGOHOST}" "${MONGOPORT}" "${F_MONGODBNAME}" \
                     "${F_MONGOUSER}" \
                     "${F_MONGOPASSWORD}" "${F_MONGOSELECT2}" >/dev/null
   end_time=$(get_timestamp_nano)
   total_time2="$(get_timestamp_diff_nano "${end_time}" "${start_time}")"

   process_log "testing mongo THIRD SELECT."
   start_time=$(get_timestamp_nano)
   run_mongo_command "${F_MONGOHOST}" "${MONGOPORT}" "${F_MONGODBNAME}" \
                    "${F_MONGOUSER}" \
                     "${F_MONGOPASSWORD}" "${F_MONGOSELECT3}" >/dev/null
   end_time=$(get_timestamp_nano)
   total_time3="$(get_timestamp_diff_nano "${end_time}" "${start_time}")"

   process_log "testing mongo FOURTH SELECT."
   start_time=$(get_timestamp_nano)
   run_mongo_command "${F_MONGOHOST}" "${MONGOPORT}" "${F_MONGODBNAME}" \
                     "${F_MONGOUSER}" \
                     "${F_MONGOPASSWORD}" "${F_MONGOSELECT4}" >/dev/null
   end_time=$(get_timestamp_nano)
   total_time4="$(get_timestamp_diff_nano "${end_time}" "${start_time}")"

   AVG="$(( ($total_time1 + $total_time2 + $total_time3 + $total_time4)/4 ))"

   echo "${AVG}"
}

################################################################################
# function: mongdb collection size
################################################################################
function mongo_collection_size ()
{
   typeset -r F_MONGOHOST="$1"
   typeset -r F_MONGOPORT="$2"
   typeset -r F_MONGODBNAME="$3"
   typeset -r F_MONGOUSER="$4"
   typeset -r F_MONGOPASSWORD="$5"
   typeset -r F_COLLECTION="$6"
   typeset -r F_COMMAND="printjson(db.getSiblingDB('${F_MONGODBNAME}').${F_COLLECTION}.stats().size)"

   process_log "calculating the size of mongo collection."
   output="$(run_mongo_command "${F_MONGOHOST}" "${F_MONGOPORT}"   \
                               "${F_MONGODBNAME}" "${F_MONGOUSER}" \
                               "${F_MONGOPASSWORD}" "${F_COMMAND}")"
   collectionsize="$(echo -n ${output})"

   echo "${collectionsize}"
}


################################################################################
# function: mongdb version
################################################################################
function mongo_version ()
{
   typeset -r F_MONGOHOST="$1"
   typeset -r F_MONGOPORT="$2"
   typeset -r F_MONGODBNAME="$3"
   typeset -r F_MONGOUSER="$4"
   typeset -r F_MONGOPASSWORD="$5"
   typeset -r F_COMMAND="db.version()"

   output="$(run_mongo_command "${F_MONGOHOST}" "${F_MONGOPORT}"   \
                               "${F_MONGODBNAME}" "${F_MONGOUSER}"  \
                               "${F_MONGOPASSWORD}" "${F_COMMAND}" )"
   version=$(echo -n $output)

   echo "${version}"
}

################################################################################
# function: mongodb create_index
################################################################################
function mongodb_create_index ()
{

   typeset -r F_MONGOHOST="$1"
   typeset -r F_MONGOPORT="$2"
   typeset -r F_MONGODBNAME="$3"
   typeset -r F_MONGOUSER="$4"
   typeset -r F_MONGOPASSWORD="$5"
   typeset -r F_COLLECTION="$6"
   typeset -r F_MONGODBIDX1="db.${F_COLLECTION}.ensureIndex( { \"name\": 1});"
   typeset -r F_MONGODBIDX2="db.${F_COLLECTION}.ensureIndex( { \"type\": 1});"
   typeset -r F_MONGODBIDX3="db.${F_COLLECTION}.ensureIndex( { \"brand\": 1});"

   process_log "creating index in mongodb."
   run_mongo_command "${F_MONGOHOST}" "${MONGOPORT}" "${F_MONGODBNAME}" \
                     "${F_MONGOUSER}" \
                     "${F_MONGOPASSWORD}" "${F_MONGODBIDX1}" >/dev/null
   run_mongo_command "${F_MONGOHOST}" "${MONGOPORT}" "${F_MONGODBNAME}" \
                     "${F_MONGOUSER}" \
                     "${F_MONGOPASSWORD}" "${F_MONGODBIDX2}" >/dev/null
   run_mongo_command "${F_MONGOHOST}" "${MONGOPORT}" "${F_MONGODBNAME}" \
                     "${F_MONGOUSER}" \
                     "${F_MONGOPASSWORD}" "${F_MONGODBIDX3}" >/dev/null

}
