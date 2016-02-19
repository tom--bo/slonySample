# Shortly after this script is executed, the replication daemon on
# $HOST2 will start to copy the current content of all 4 replicated
# tables.  While doing so, of course, the pgbench application will
# continue to modify the database.  When the copy process is finished,
# the replication daemon on $HOST2 will start to catch up by applying
# the accumulated replication log.  It will do this in little steps, 10
# seconds worth of application work at a time.  Depending on the
# performance of the two systems involved, the sizing of the two
# databases, the actual transaction load and how well the two databases
# are tuned and maintained, this catchup process can be a matter of
# minutes, hours, or infinity.
# 
# Checking the result
# -----------------------------
# 
# To check the result of the replication attempt (actually, the
# intention was to create an exact copy of the first node, no?) the
# pgbench application must be stopped and any eventual replication
# backlog processed by node 2.  After that, we create data exports (with
# ordering) of the 2 databases and compare them:
# 
# Script slony_sample1_compare.sh

#!/bin/sh

CLUSTER=test1
DBNAME1=pgbench_node1
DBNAME2=pgbench_node2
HOST1=<host name of pgbench_node1>
HOST2=<host name of pgbench_node2>
SLONY_USER=<postgres superuser to connect as for replication>
PGBENCH_USER=<normal user to run the pgbench application>

echo -n "**** comparing sample1 ... "
psql -U $PGBENCH_USER -h $HOST1 $DBNAME1 >dump.tmp.1.$$ <<_EOF_
    select 'accounts:'::text, aid, bid, abalance, filler
        from accounts order by aid;
    select 'branches:'::text, bid, bbalance, filler
        from branches order by bid;
    select 'tellers:'::text, tid, bid, tbalance, filler
        from tellers order by tid;
    select 'history:'::text, tid, bid, aid, delta, mtime, filler,
        id
        from history order by id;
_EOF_


psql -U $PGBENCH_USER -h $HOST2 $DBNAME2 >dump.tmp.2.$$ <<_EOF_
    select 'accounts:'::text, aid, bid, abalance, filler
        from accounts order by aid;
    select 'branches:'::text, bid, bbalance, filler
        from branches order by bid;
    select 'tellers:'::text, tid, bid, tbalance, filler
        from tellers order by tid;
    select 'history:'::text, tid, bid, aid, delta, mtime, filler,
        id
        from history order by id;
_EOF_

if diff dump.tmp.1.$$ dump.tmp.2.$$ >test_1.diff ; then
    echo "success - databases are equal."
    rm dump.tmp.?.$$
    rm test_1.diff
else
    echo "FAILED - see test_1.diff for database differences"
fi

If this script reports any differences, it is worth reporting this to
the developers as we would appreciate hearing how this happened.
