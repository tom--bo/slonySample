# Time to replicate
# -------------------
# 
# Is the pgbench application still running?
# 
# At this point we have 2 databases that are fully prepared.  One is the
# master database accessed by the pgbench application.  It is time now
# to start the replication daemons.
# 
# On the system $HOST1, the command to start the replication daemon is
# 
# slon $CLUSTER "dbname=$DBNAME1 user=$SLONY_USER"
# 
# Since the replication daemon for node 1 is running on the same host as
# the database for node 1, there is no need to connect via TCP/IP socket
# for it.
# 
# Likewise we start the replication daemon for node 2 on $HOST2 with
# 
# slon $CLUSTER "dbname=$DBNAME2 user=$SLONY_USER"
# 
# Even if the two daemons now will start right away and show a lot of
# message exchanging, they are not replicating any data yet.  What is
# going on is that they synchronize their information about the cluster
# configuration.
# 
# To start replicating the 4 pgbench tables from node 1 to node 2 we
# have to execute the following script:
# 
# slony_sample1_subscribe.sh:

#!/bin/sh

CLUSTER=test1
DBNAME1=pgbench_node1
DBNAME2=pgbench_node2
HOST1=<host name of pgbench_node1>
HOST2=<host name of pgbench_node2>
SLONY_USER=<postgres superuser to connect as for replication>
PGBENCH_USER=<normal user to run the pgbench application>

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
    subscribe set ( id = 1, provider = 1, receiver = 2, forward = no);
_EOF_

