#!/usr/bin/env bash

### sudo bash  /srv/scripts/backup/backup.sh

date="$(date "+%Y-%m-%d-%H-%M")"
MAGENTO_ROOT="/var/www/html/magento"
BACKUP_PATH="${MAGENTO_ROOT}/var/backups"
AWS_BACKUP_DIR="aws-magento-backup"
LOCAL_LIMIT_DAYS="+14"
AWS_LIMIT_DAYS="90"

### Checking Parameters for email delivery
usage () {
        echo "Usage: `basename ${0}` [-e] -- program to Backup Magento files and Database.

        where:
           -e  enable mail notification [Disabled by default].
                "
}

checkarg () {
if [[ $OPTARG =~ ^-[e]$ ]]; then usage; exit 1; fi
}

while getopts ":e" opt; do
  case $opt in
    e) checkarg
    SEND_MAIL="true"
        ;;
    *) usage; exit 1
    ;;
  esac
done


main () {
echo""
### Enable maintenance mode
echo "Enable maintenance mode..."
/usr/local/bin/n98-magerun2 sys:maintenance --on --skip-root-check --root-dir=${MAGENTO_ROOT}
echo ""


### Create database dump
echo "Creating database dump ..."
/usr/local/bin/n98-magerun2 --skip-root-check --root-dir=${MAGENTO_ROOT} db:dump ${BACKUP_PATH}/db-backup-$date.sql
RETURN_VALUE="$?"

    if [ "${RETURN_VALUE}" -ne "0" ]; then
        echo "Creating database dump is failed";
        exit 1;
    else
        echo "Done"
        echo ""
    fi

### Create archive of webroot, excluding var
echo "Creating tar archive of webroot files excluding var to file ${BACKUP_PATH}/files-backup-$date.tar.gz ..."
cd $MAGENTO_ROOT && \
tar -cpzf ${BACKUP_PATH}/files-backup-$date.tar.gz --exclude=var/* .
RETURN_VALUE="$?"

    if [ "${RETURN_VALUE}" -ne "0" ]  && [ "${RETURN_VALUE}" -ne "1" ]; then
        echo "Creating tar archive of webroot files is failed";
        exit 1;
    else
        echo "Done"
        echo ""
    fi

### Upload to s3
    if echo "Uploading to S3..."; then
    aws s3 cp ${BACKUP_PATH}/files-backup-$date.tar.gz s3://${AWS_BACKUP_DIR}
    aws s3 cp ${BACKUP_PATH}/db-backup-$date.sql s3://${AWS_BACKUP_DIR}
    echo""
    echo "Done"

    fi

### Disable maintenance mode
echo "Disable maintenance mode..."
/usr/local/bin/n98-magerun2 sys:maintenance --off --skip-root-check --root-dir=${MAGENTO_ROOT}
echo ""

### Delete backups older that 14 days from local
echo "Deleting backups older ${LIMIT_DAYS} days from local server..."
find ${BACKUP_PATH} -type f \( -name "files-backup-*.tar.gz" -o -name "db-backup-*.sql" \) -mtime ${LOCAL_LIMIT_DAYS} -exec rm -rf {} \;
RETURN_VALUE="$?"

    if [ "${RETURN_VALUE}" -ne "0" ]; then
        echo "Deleting old local backups is failed. Aborting..."
        exit 1;
    else
           echo "Done"
       echo""
    fi

### Delete backups older 90 days from aws
echo "Deleting backups older than  ${AWS_LIMIT_DAYS} days from aws..."
aws_files=`aws s3 ls ${AWS_BACKUP_DIR}`
LST_AWS_RETURN_VALUE="$?"
if [ "${LST_AWS_RETURN_VALUE}" -ne "0" ]; then
 echo "Could't Access aws instanse..."
 exit 1;
else
 today_date=`(date -d $(date +%Y-%m-%d) '+%s')`

 for file in $aws_files;
 do
  files_bkup=`echo $file | grep "files-backup\|db-backup"`

  if [ $? == 0 ];then
    file_date=`echo $files_bkup | cut -d . -f 1 | cut -d - -f3,4,5`
    file_date2=`(date -d $file_date '+%s')`
    DIFFDAYS=$(( ($today_date - $file_date2) / (60*60*24) ))
    if [ $DIFFDAYS -gt ${AWS_LIMIT_DAYS} ];then
       aws s3 rm s3://${AWS_BACKUP_DIR}/${files_bkup}
           RETURN_VALUE="$?"
    fi
  fi
 done
 if [ "${RETURN_VALUE}" -ne "0" ]; then
        echo "Deleting old backups from aws is failed"
        exit 1;
    else
          echo "Done"
      echo ""
 fi
fi
printf "Backup Finished.\n"
}

if [ "${SEND_MAIL}" == "true" ];then
  main | tee  /tmp/mail.txt
  bash /srv/scripts/backup/mailer.sh
else
  main
fi
