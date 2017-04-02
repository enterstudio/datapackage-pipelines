#!/bin/sh
if [ "$1" = "server" ]; then 
    export DPP_REDIS_HOST=127.0.0.1
    echo "Starting Server"
    redis-server /etc/redis.conf --appendonly yes --daemonize yes --dir /var/redis
    until [ `redis-cli ping | grep -c PONG` = 1 ]; do echo "Waiting 1s for Redis to load"; sleep 1; done
    rm -f celeryd.pid
    python3 -m celery --detach -b redis://localhost:6379/0 --concurrency=4 -B -A datapackage_pipelines.app -Q datapackage-pipelines -l INFO worker
    dpp serve
else
    /usr/local/bin/dpp "$@"
fi;


