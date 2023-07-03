#!/bin/bash

{
    set -e
    set -o pipefail

    echo ":: Initialization started"
    date

    echo ":: Disabling transparent_hugepage"
    echo never > /rootfs/sys/kernel/mm/transparent_hugepage/enabled
    echo never > /rootfs/sys/kernel/mm/transparent_hugepage/defrag
    grep -q -F [never] /sys/kernel/mm/transparent_hugepage/enabled
    grep -q -F [never] /sys/kernel/mm/transparent_hugepage/defrag

    echo ":: Creating data folder"
    install -d -o mongodb -g mongodb /data/alertdb/alertdb/mongodb
    chown -R mongodb:mongodb /data/alertdb/alertdb/mongodb

    echo ":: Creating certificate"
    openssl req -x509 -newkey rsa:4096 -keyout /etc/ssl/alertdb.pem -out /etc/ssl/alertdb.pem -days 365 -nodes \
        -subj '/O=NTT Security/OU=NTTS AS-DEV/CN=statefulset-alertdb-0.aspod.svc.cluster.local' \
        -addext 'subjectAltName=DNS:localhost,DNS:service-alertdb.aspod.svc.cluster.local' \
        2>&1

    wait

    chmod 640 /etc/ssl/alertdb.pem
    chown root:mongodb /etc/ssl/alertdb.pem

    echo ":: Initialization finished."
} | tee -a /init-alertdb.log

echo ":: Starting alertdb"

set -x
exec docker-entrypoint.sh \
    mongod \
        --dbpath /data/alertdb/alertdb/mongodb --directoryperdb \
        --auth --tlsMode requireTLS --tlsCertificateKeyFile /etc/ssl/alertdb.pem \
        --replSet rs0 --oplogSize 24576 \
        --wiredTigerCacheSizeGB 4 \
        --bind_ip_all

