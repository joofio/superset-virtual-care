#FROM apache/superset:2.0.0-dev
FROM apache/superset:latest-dev

#using 2.0.0-dev due to  https://github.com/apache/superset/issues/22326
USER root
# Example: installing the MySQL driver to connect to the metadata database
# if you prefer Postgres, you may want to use `psycopg2-binary` instead

RUN  apt-get update -y \
        && apt-get install -y --no-install-recommends \
            	    wget \
	    unzip \ 
        libaio1 \
        && rm -rf /var/lib/apt/lists/*
# Example: installing a driver to connect to Redshift
# Find which driver you need based on the analytics database
# you want to connect to here:
# https://superset.apache.org/installation.html#database-dependencies

WORKDIR /
RUN wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip 
RUN   unzip instantclient-basiclite-linuxx64.zip 
RUN    rm -f instantclient-basiclite-linuxx64.zip 
RUN ls
RUN    cd instantclient_21_9 && \
mkdir lib && \
cp libc* lib/ && \
cp libo* lib/ && \
cp libn* lib/ && \
    rm -f *jdbc* *occi* *mysql* *jar uidrvci genezi adrci && \
    echo /instantclient_21_9 > /etc/ld.so.conf.d/oracle-instantclient.conf && \
        echo /instantclient_21_9/lib > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    ldconfig
RUN pwd

ENV TERM=vt100
ENV ORACLE_HOME="/instantclient_21_9"
ENV LD_LIBRARY_PATH="/instantclient_21_9"
RUN export PATH=$PATH:/instantclient_21_9

RUN pip install cx_Oracle
RUN pip install --force-reinstall git+https://github.com/benoitc/gunicorn.git@master
#why? -> https://github.com/apache/superset/issues/20768

# Switching back to using the `superset` user
WORKDIR /app

USER superset