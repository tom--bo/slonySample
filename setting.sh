# Configuring the databases for replication
# ------------------------------------------
# 
# Creating the configuration tables, stored procedures, triggers and
# setting up the configuration is done with the slonik command.  It is a
# specialized scripting aid that mostly calls stored procedures in the
# node databases.  The script to create the initial configuration for a
# simple master-slave setup of our pgbench databases looks like this:
# Script slony_sample1_setup.sh

#!/bin/sh

CLUSTER=slony_example
DBNAME1=pgbench
DBNAME2=pgbenchslave
HOST1=localhost
HOST2=localhost
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
    # Initialize the first node.  The id must be 1.
    # This creates the schema "_test1" containing all replication
    # system specific database objects.
    # ----
    init cluster ( id = 1, comment = 'Node 1' );

    # ----
    # The Slony replication system organizes tables in sets.  The
    # smallest unit another node can subscribe is a set.  Usually the
    # tables contained in one set would be all tables that have
    # relationships to each other.  The following commands create
    # one set containing all 4 pgbench tables.  The "master" or origin
    # of the set is node 1.
    # ----
    create set ( id = 1, origin = 1, comment = 'All pgbench tables' );
    set add table ( set id = 1, origin = 1,
        id = 1, fully qualified name = 'public.pgbench_accounts',
        comment = 'Table accounts' );
    set add table ( set id = 1, origin = 1,
        id = 2, fully qualified name = 'public.pgbench_branches',
        comment = 'Table branches' );
    set add table ( set id = 1, origin = 1,
        id = 3, fully qualified name = 'public.pgbench_tellers',
        comment = 'Table tellers' );
    set add table ( set id = 1, origin = 1,
        id = 4, fully qualified name = 'public.pgbench_history',
        comment = 'Table history' );

    # ----
    # Create the second node, tell the two nodes how to connect to 
    # each other and that they should listen for events on each
    # other.  Note that these conninfo arguments are used by the
    # slon daemon on node 1 to connect to the database of node 2
    # and vice versa.  So if the replication system is supposed to
    # use a separate backbone network between the database servers,
    # this is the place to tell it.
    # ----
    store node ( id = 2, comment = 'Node 2' );
    store path ( server = 1, client = 2,
        conninfo = 'dbname=$DBNAME1 host=$HOST1 user=$SLONY_USER');
    store path ( server = 2, client = 1,
        conninfo = 'dbname=$DBNAME2 host=$HOST2 user=$SLONY_USER');
    store listen ( origin = 1, provider = 1, receiver = 2 );
    store listen ( origin = 2, provider = 2, receiver = 1 );
_EOF_

