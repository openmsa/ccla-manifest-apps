#!/bin/bash

{
    echo ":: Setup script started"
    date

    echo ":: Ensuring the oplog is initiated"
    count=0
    while ! mongo --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --tls --tlsAllowInvalidCertificates --eval "rs.initiate();" 2>&1 ; do
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
            {'user': '$ALERTDB_STALKER_USERNAME', 'pwd': '$ALERTDB_STALKER_PASSWORD', 'roles': [{'db': 'alerts', 'role': 'readWrite'}]},
            {'user': '$ALERTDB_DUMPSTER_USERNAME', 'pwd': '$ALERTDB_DUMPSTER_PASSWORD', 'roles': [{'db': 'alerts', 'role': 'readWrite'}, {'db': 'messages', 'role': 'readWrite'}]},
            {'user': '$ALERTDB_CHARON_USERNAME', 'pwd': '$ALERTDB_CHARON_PASSWORD', 'roles': [{'db': 'alerts', 'role': 'read'}, {'db': 'local', 'role': 'read'}]},
            {'user': '$ALERTDB_GUIHELPER_USERNAME', 'pwd': '$ALERTDB_GUIHELPER_PASSWORD', 'roles': [{'db': 'alerts', 'role': 'readWrite'}]},
            {'user': '$ALERTDB_MVIEW_USERNAME', 'pwd': '$ALERTDB_MVIEW_PASSWORD', 'roles': [{'db': 'alerts', 'role': 'read'}]},
            {'user': '$ALERTDB_REPLICATOR_USERNAME', 'pwd': '$ALERTDB_REPLICATOR_PASSWORD', 'roles': [{'db': 'alerts', 'role': 'readWrite'}, {'db': 'local', 'role': 'read'}]},
            {'user': '$ALERTDB_PRUNERS_USERNAME', 'pwd': '$ALERTDB_PRUNERS_PASSWORD', 'roles': [{'db': 'alerts', 'role': 'readWrite'}]},
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
} | tee -a /setup-alertdb.log

