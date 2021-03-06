#!/bin/sh

createdb -O $PGBENCHUSER -h $MASTERHOST $MASTERDBNAME
createdb -O $PGBENCHUSER -h $SLAVEHOST_1 $SLAVEDBNAME
createdb -O $PGBENCHUSER -h $SLAVEHOST_2 $SLAVEDBNAME
pgbench -i -s 1 -U $PGBENCHUSER -h $MASTERHOST $MASTERDBNAME

psql -U $PGBENCHUSER -h $MASTERHOST -d $MASTERDBNAME -c "
	begin;
	alter table pgbench_history add column id serial;
	update pgbench_history set id = nextval('pgbench_history_id_seq');
	alter table pgbench_history add primary key(id);
	commit;
"

pg_dump -s -U $REPLICATIONUSER -h $MASTERHOST $MASTERDBNAME | psql -U $REPLICATIONUSER -h $SLAVEHOST_1 $SLAVEDBNAME
pg_dump -s -U $REPLICATIONUSER -h $MASTERHOST $MASTERDBNAME | psql -U $REPLICATIONUSER -h $SLAVEHOST_2 $SLAVEDBNAME

