#!/usr/bin/env bash

### sudo bash /srv/scripts/backup/rollback.sh

MAGENTO_ROOT="/var/www/html/magento"

SYSTEM_USER="www-data"
SYSTEM_GROUP="devbox"

MYSQL_USER="devbox"
MYSQL_PASSWORD="devmysql"
MYSQL_DATABASE="magento"
MYSQL_HOST="127.0.0.1"

usage () {
        echo "Usage: ${0} [-f files_backup_file_name] [-d database_backup_file_name]"
}

checkarg () {
if [[ $OPTARG =~ ^-[f/d/]$ ]]; then usage; exit 1; fi
}

while getopts ":f:d:" opt; do
  case $opt in
    f) checkarg
    FILES_BACKUP_FILE_NAME="$OPTARG"
    ;;
    d) checkarg
    DATABASE_BACKUP_FILE_NAME="$OPTARG"
    ;;
    *) usage; exit 1
    ;;
  esac
done

### Check whether at least one required parameter is defined
       if [ -z ${FILES_BACKUP_FILE_NAME} ] && [ -z ${DATABASE_BACKUP_FILE_NAME} ]; then
               usage; exit 1
       fi


### Function for recovery files
recovery_files () {
        echo "Recovery FILES from backup file ${FILES_BACKUP_FILE_NAME}..."
        echo ""
        tar -xzf ${FILES_BACKUP_FILE_NAME} -C ${MAGENTO_ROOT}/
        RETURN_VALUE="$?"

             if [ "${RETURN_VALUE}" -ne "0" ] && [ "${RETURN_VALUE}" -ne "1" ]; then
                echo "Recovery FILES from backup file ${FILES_BACKUP_FILE_NAME} is failed";
                exit 1;
             else
                echo "Done"
		echo ""
             fi

        echo "Change owner and group for ${MAGENTO_ROOT} on ${SYSTEM_USER}:${SYSTEM_GROUP}..."
        chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} ${MAGENTO_ROOT}
        echo "Done"
        echo ""
}


### Function for recovery database
recovery_database () {
        echo "Recovery DATABSE from backup file ${DATABASE_BACKUP_FILE_NAME}..."
        echo ""

        /usr/local/bin/n98-magerun2 --skip-root-check --root-dir=${MAGENTO_ROOT} db:import ${DATABASE_BACKUP_FILE_NAME}
        RETURN_VALUE="$?"

             if [ "${RETURN_VALUE}" -ne "0" ]; then
                echo "Recovery DATABASE from backup file ${DATABASE_BACKUP_FILE_NAME} is failed";
                exit 1;
             else
                echo "Done"
                echo ""
             fi

}

### Enable maintenance mode
echo "Enable maintenance mode..."
/usr/local/bin/n98-magerun2 sys:maintenance --on --skip-root-check --root-dir=${MAGENTO_ROOT}


### Recovery files
       if [ ! -z ${FILES_BACKUP_FILE_NAME} ] ; then
               echo ""
               recovery_files
       fi

### Recovery database
       if [ ! -z ${DATABASE_BACKUP_FILE_NAME} ] ; then
               echo ""
               recovery_database
       fi

### Clean Magento Cache
       if  echo "Clean Magento Cache..."  ; then
          /usr/local/bin/n98-magerun2 cache:clean --skip-root-check --root-dir=${MAGENTO_ROOT}
          echo "Done"
          echo ""
       fi

### Disable maintenance mode
echo "Disable maintenance mode..."
/usr/local/bin/n98-magerun2 sys:maintenance --off --skip-root-check --root-dir=${MAGENTO_ROOT}
echo ""
