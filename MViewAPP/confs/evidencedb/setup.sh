#!/bin/bash

{
    echo ":: Setup script started"
    date

    echo ":: Ensuring MongoDB is up"
    count=0
    while ! mongo --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --tls --tlsAllowInvalidCertificates --eval "db.version();" 2>&1 ; do
        ((count++))
        if [[ $count -gt 20 ]] ; then
            echo "==> Failed after 20 attempts, exiting with exit code 1."
            exit 1
        fi
        echo "==> Retrying in 3 seconds..."
        sleep 3
    done

    set -e -o pipefail

    echo ":: Creating accounts"
    mongo --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --tls --tlsAllowInvalidCertificates --eval "
        const accounts = [
            {'user': '$EVIDENCEDB_STALKER_USERNAME', 'pwd': '$EVIDENCEDB_STALKER_PASSWORD', 'roles': [{'db': 'siemaas', 'role': 'readWrite'}]},
            {'user': '$EVIDENCEDB_DUMPSTER_USERNAME', 'pwd': '$EVIDENCEDB_DUMPSTER_PASSWORD', 'roles': [{'db': 'siemaas', 'role': 'readWrite'}, {'db': 'heartbeats', 'role': 'readWrite'}, {'db': 'fetcherdb', 'role': 'readWrite'}]},
            {'user': '$EVIDENCEDB_GUIHELPER_USERNAME', 'pwd': '$EVIDENCEDB_GUIHELPER_PASSWORD', 'roles': [{'db': 'siemaas', 'role': 'readWrite'}]},
            {'user': '$EVIDENCEDB_MVIEW_USERNAME', 'pwd': '$EVIDENCEDB_MVIEW_PASSWORD', 'roles': [{'db': 'siemaas', 'role': 'read'}]},
            {'user': '$EVIDENCEDB_REPLICATOR_USERNAME', 'pwd': '$EVIDENCEDB_REPLICATOR_PASSWORD', 'roles': [{'db': 'siemaas', 'role': 'readWrite'}, {'db': 'siemaas', 'role': 'read'}]},
            {'user': '$EVIDENCEDB_PRUNERS_USERNAME', 'pwd': '$EVIDENCEDB_PRUNERS_PASSWORD', 'roles': [{'db': 'siemaas', 'role': 'readWrite'}]},
        ];
        const adminDb = db.getSiblingDB('admin');
        for (i=0; i<accounts.length; i++) {
            var account = accounts[i];
            var username = account['user'];
            try {
                adminDb.createUser(account);
                print('==> Account ' + username + ' created.');
                continue;
            } catch(err) {
                print('==> Failed to create ' + username + ' account: ' + err);
            }
            delete account['user'];
            try {
                adminDb.updateUser(username, account);
                print('==> Account ' + username + ' updated.');
            } catch(err) {
                print('==> Failed to update ' + username + ' account: ' + err);
            }
        }
    " 2>&1

    echo ":: Setup script finished."
} | tee -a /setup-evidencedb.log

