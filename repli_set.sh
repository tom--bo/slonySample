#!/bin/sh

CLUSTER=slony_example
DBNAME1=pgbench
DBNAME2=pgbenchslave
SLONY_USER=pgsql

slon $CLUSTER "dbname=$DBNAME1 user=$SLONY_USER"
slon $CLUSTER "dbname=$DBNAME2 user=$SLONY_USER"

_EOF_

