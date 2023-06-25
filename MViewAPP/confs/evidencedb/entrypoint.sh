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
    install -d -o mongodb -g mongodb /data/evidencedb/evidencedb/mongodb
    chown -R mongodb:mongodb /data/evidencedb/evidencedb/mongodb

    echo ":: Creating certificate"
    openssl req -x509 -newkey rsa:4096 -keyout /etc/ssl/evidencedb.pem -out /etc/ssl/evidencedb.pem -days 365 -nodes \
        -subj '/O=NTT Security/OU=NTTS AS-DEV/CN=statefulset-evidencedb-0.aspod.svc.cluster.local' \
        -addext 'subjectAltName=DNS:localhost,DNS:service-evidencedb.aspod.svc.cluster.local' \
        2>&1

    wait

    chmod 640 /etc/ssl/evidencedb.pem
    chown root:mongodb /etc/ssl/evidencedb.pem

    echo ":: Initialization finished."
} | tee -a /init-evidencedb.log

echo ":: Starting evidencedb"

set -x
exec docker-entrypoint.sh \
    mongod \
        --dbpath /data/evidencedb/evidencedb/mongodb --directoryperdb \
        --auth --tlsMode requireTLS --tlsCertificateKeyFile /etc/ssl/evidencedb.pem \
        --wiredTigerCacheSizeGB 4 \
        --bind_ip_all

