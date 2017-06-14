#!/bin/bash

if [ "$1" == "config" ]; then
    REDIS_IP="$2"
    POSTGRES_IP="$3"
    AIRFLOW_CMD="${@:4}"
    cp /usr/local/airflow/script/airflow_entrypoint.sh /tmp/airflow_entrypoint.sh
    python3 /usr/local/airflow/script/configure.py $REDIS_IP $POSTGRES_IP /tmp/airflow_entrypoint.sh
    bash /tmp/airflow_entrypoint.sh $AIRFLOW_CMD
else
    AIRFLOW_CMD="${@:1}"
    bash /usr/local/airflow/script/airflow_entrypoint.sh $AIRFLOW_CMD
fi

