#!/bin/sh

CLUSTER=slony_example
DBNAME1=pgbench
DBNAME2=pgbench
HOST1=192.168.33.21
HOST2=192.168.33.22
SLONY_USER=pgsql

slonik <<_EOF_
    
    cluster name = $CLUSTER;

    node 1 admin conninfo = 'dbname=$DBNAME1 host=$HOST1 user=$SLONY_USER';
    node 2 admin conninfo = 'dbname=$DBNAME2 host=$HOST2 user=$SLONY_USER';

    lock set (id = 1, origin = 1);
    wait for event (origin = 1, confirmed = 2);
    move set (id = 1, old origin = 1, new origin = 2);
    wait for event (origin = 1, confirmed = 2, wait on = 1);

_EOF_

