FROM python:3.6
MAINTAINER Daniel Kristiyanto <daniel@kensci.com>

# Image: kensci/airflow

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux
ENV AIRFLOW__CORE__EXECUTOR CeleryExecutor
ENV AIRFLOW__CORE__LOAD_EXAMPLES FALSE
ENV AIRFLOW__CORE__DAGS_FOLDER /usr/local/airflow/dags
ENV AIRFLOW__CORE__DAG_CONCURRENCY 32
ENV AIRFLOW__CORE__DAG_MAX_ACTIVE_RUNS_PER_DAG 16
ENV AIRFLOW__SCHEDULER__CATCHUP_BY_DEFAULT FALSE
ENV AIRFLOW__WEBSERVER__AUTHENTICATE FALSE
ENV AIRFLOW__WEBSERVER__DAG_ORIENTATION TB
ENV AIRFLOW__WEBSERVER__WEB_SERVER_PORT 8080
ENV AIRFLOW__WEBSERVER__BASE_URL http://localhost:8080
ENV AIRFLOW__WEBSERVER__EXPOSE_CONFIG TRUE
ENV AIRFLOW__OPERATORS__DEFAULT_OWNER KenSci
ENV AIRFLOW__OPERATORS__DEFAULT_CPUS 1
ENV AIRFLOW__OPERATORS__DEFAULT_RAM 1024
ENV AIRFLOW__OPERATORS__DEFAULT_DISK 1024
ENV AIRFLOW__OPERATORS__DEFAULT_GPUS 0
ENV AIRFLOW__CELERY__FLOWER_HOST flower
ENV AIRFLOW__CELERY__CELERYD_CONCURRENCY 8
ENV AIRFLOW__CORE__FERNET_KEY dBRAbQkNzKQQ-3wIda0N_0vvEK1KNcJBZDKanPlWmmk=
# Airflow
ARG AIRFLOW_VERSION=1.8.0
ARG AIRFLOW_HOME=/usr/local/airflow

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get update && apt-get install -y apt-transport-https ca-certificates

RUN set -ex \
    && buildDeps=' \
        python3-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        build-essential \
        libblas-dev \
        liblapack-dev \
        libpq-dev \
        git \
        unixodbc \
        unixodbc-dev \
        tdsodbc \
        libssl-dev \
        libffi-dev \
        build-essential \
    ' \
    && apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        apt-utils \
        curl \
        netcat \
        locales \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && pip install Cython \
    && pip install docker-py \
    && pip install odo \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install pyodbc \
    && pip install airflow[crypto,celery,postgres,password,hdfs,jdbc,ldap,kerberos,slack]==$AIRFLOW_VERSION \
    && pip install celery[redis]==3.1.17 \
    && pip install pycurl \
    && apt-get remove --purge -yqq $buildDeps \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base


COPY script/ /usr/local/airflow/script/
COPY dags/ /usr/local/airflow/dags/
COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

RUN chown -R airflow: ${AIRFLOW_HOME}

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/usr/local/airflow/script/entrypoint.sh"]
