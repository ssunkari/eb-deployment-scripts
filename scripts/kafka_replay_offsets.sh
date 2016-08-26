#!/bin/bash
#This shell script rewinds the offset position to last zookeeper offset snapshot for all partitions on all topics

 SSH_KEY_PATH=$1
 BACKUP_INSTANCE_IP=$2
 RESTORE_FROM_ENV=$3
 SUDO_USER=$4
 ZOOKEEPER_INSTANCES=$5
 # Below regex is to filter any crap topics which we are not interested about
 KAFKA_TOPIC_REGEX=$6
 AWS_ACCESS_KEY_ID=$7
 AWS_SECRET_ACCESS_KEY=$8

 ssh $SUDO_USER@$BACKUP_INSTANCE_IP -i $SSH_KEY_PATH  "\
 # rm -rf ~/replay \
 # && mkdir -p ~/replay && cd ~/replay \
 && export AWS_ACCESS_KEY_ID=AKIAJTPO5HZFCTRXPN7A \
 && export AWS_SECRET_ACCESS_KEY=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 \
 && /usr/local/bin/aws s3 sync s3://go-artifacts-store/couchbase/backups/$RESTORE_FROM_ENV/ . \
 && echo 'backup copied to target machine!!!!yay' \
 && cat offsets_*.txt | sed -n '/$KAFKA_TOPIC_REGEX/p' > offsets.txt \
 && echo 'started replaying kafka resets on instances $ZOOKEEPER_INSTANCES' \
 && /usr/bin/kafka-run-class kafka.tools.ImportZkOffsets -zkconnect $ZOOKEEPER_INSTANCES --input-file offsets.txt \
 && echo 'replay finished on $ZOOKEEPER_INSTANCES'" 


# sh ./kafka_replay_offsets.sh ~/.ssh/rateplans.pem 10.199.4.124 rates-uat lradmin 10.199.6.214:2181,10.199.6.215:2181,10.199.6.216:2181 acquisitions\..*\.change_set

