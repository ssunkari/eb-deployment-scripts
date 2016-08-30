#!/bin/bash

# This script will restore the couchbase from previous backup for given environment, 

 SSH_KEY_PATH=$1
 BACKUP_INSTANCE_IP=$2
 RESTORE_FROM_ENV=$3
 SUDO_USER=$4
 TARGET_COUCHBASE_INSTANCE_IP=$5
 TARGET_COUCHBASE_INSTANCE_PORT=$6
 SOURCE_BUCKET=$7
 DEST_BUCKET=$8
 CB_USERNAME=$9
 CB_PASSWORD=$10
 AWS_ACCESS_KEY_ID=$11
 AWS_SECRET_ACCESS_KEY=$12


 ssh $SUDO_USER@$BACKUP_INSTANCE_IP -i $SSH_KEY_PATH 'rm -rf ~/restore \
 && mkdir -p ~/restore && cd ~/restore \
 && export AWS_ACCESS_KEY_ID=AKIAJTPO5HZFCTRXPN7A \
 && export AWS_SECRET_ACCESS_KEY=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 \
 && /usr/local/bin/aws s3 sync s3://go-artifacts-store/couchbase/backups/$RESTORE_FROM_ENV $RESTORE_FROM_ENV \
 && echo "backup copied to target machine!!!!yay" \
 && echo "started restoring couchbase backup on instance with ip: $TARGET_COUCHBASE_INSTANCE_IP:$TARGET_COUCHBASE_INSTANCE_PORT $SOURCE_BUCKET $DEST_BUCKET $CB_USERNAME  $CB_PASSWORD"  \
 && python /opt/couchbase/cli/cbrestore ~/restore/$RESTORE_FROM_ENV/ "http://$TARGET_COUCHBASE_INSTANCE_IP:$TARGET_COUCHBASE_INSTANCE_PORT" --bucket-source=$SOURCE_BUCKET --bucket-destination=$DEST_BUCKET -u $CB_USERNAME -p $CB_PASSWORD \
 && echo "restore finished on $TARGET_COUCHBASE_INSTANCE_IP"'

# sh ./cb_kafka_restore_from_backup.sh ~/.ssh/rateplans.pem 10.199.4.124 rates-uat lradmin 10.199.6.99 8091 ratesandavailability ratesandavailability ratesservice mysecretword 

