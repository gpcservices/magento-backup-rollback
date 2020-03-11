# Bash Script: magento backup rollback


![Version 1.1.0](https://img.shields.io/badge/Version-1.1.0-green.svg)

With this script you can create backup and make `automatically` rollback of your Magento installation, either database or files. The script is based on Magerun.


## Getting Started

These instructions will get you a copy of the tools up and running on your local machine for development and testing purposes. 
### Prerequisites

* [Magerun](https://github.com/netz98/n98-magerun2) - The netz98 magerun CLI tools used.


### Installation


```
git clone https://github.com/quantiota/magento-backup-rollback 
mkdir /srv/scripts/backup
cd magento-backup-rollback
mv backup.sh rollback.sh  /srv/scripts/backup
```

## Usage:
### Default Variables:
Some default values are defined on the utility such as `backup location` and Magento `DocumentRoot`, Please change those variable according to your setup.

`MAGENTO_ROOT` default value is  `/var/www/html/magento`

`BACKUP_PATH` default value is `/var/www/html/magento/var/backups`

### Options
The `backup.sh` script does not accept any options.

The `rollback.sh` script accepts three options:

    -f : To specify the archived files version to be restored.
    
    -d : To specify the archived database version to be restored.
    
    -a : To restore automatically the last archived files and database version.
    
## Examples
### To backup files and database into default location:
`sudo bash  /srv/scripts/backup/backup.sh`

`backup version 2020-03-01-00-28`


### To restore  files:
`sudo bash /srv/scripts/backup/rollback.sh -f /path/to/files-backup-2020-03-01-00-28.tar.gz`

### To restore database:
`sudo bash /srv/scripts/backup/rollback.sh -d /path/to/db-backup-2020-03-01-00-28.sql`

### To restore both files and database :
`sudo bash /srv/scripts/backup/rollback.sh -f /path/to/files-backup-2020-03-01-00-28.tar.gz -d /path/to/db-backup-2020-03-01-00-28.sql`

### To restore automatically the last files and database :
`sudo bash /srv/scripts/backup/rollback.sh -a`


## License

Github Changelog Generator is released under the [MIT License](http://www.opensource.org/licenses/MIT).
