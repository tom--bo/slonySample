#!/bin/sh

CLUSTER=slony_example
DBNAME1=pgbench
DBNAME2=pgbenchslave
HOST1=localhost
HOST2=localhost
SLONY_USER=pgsql
PGBENCH_USER=pgbench

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
