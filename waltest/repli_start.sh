#!/bin/sh

CLUSTER=slony_example
DBNAME1=pgbench
DBNAME2=pgbench
HOST1=192.168.33.101
HOST2=192.168.33.103
SLONY_USER=pgsql
PGBENCH_USER=pgbench

slonik <<_EOF_
    # ----
    # This defines which namespace the replication system uses
    # ----
    cluster name = $CLUSTER;

    # ----
    # Admin conninfo's are used by the slonik program to connect
    # to the node databases.  So these are the PQconnectdb arguments
    # that connect from the administrators workstation (where
    # slonik is executed).
    # ----
    node 1 admin conninfo = 'dbname=$DBNAME1 host=$HOST1 user=$SLONY_USER';
    node 2 admin conninfo = 'dbname=$DBNAME2 host=$HOST2 user=$SLONY_USER';

    # ----
    # Node 2 subscribes set 1
    # ----
    subscribe set ( id = 1, provider = 1, receiver = 2, forward = yes);
_EOF_

