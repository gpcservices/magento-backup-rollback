# Bash Script: magento backup rollback

![Version 1.2.0](https://img.shields.io/badge/Version-1.2.0-green.svg)

With this script you can create backup `using cron` to Amazon S3 with email notification and make `automatically` rollback of your Magento installation, either database or files.


## Getting Started

These instructions will get you a copy of the tools up and running on your live system.
### Prerequisites

* [AWS account](https://aws.amazon.com/fr/s3/) - Create an Amazon S3 account.
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-bundle.html) - Using the Bundled Installer.
* [AWS SES](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/send-email-smtp-client-command-line.html#send-email-using-openssl) - Using the Amazon SES SMTP interface.
* [Magerun](https://github.com/netz98/n98-magerun2) - The netz98 magerun CLI tools used.
* [m2-ce-cron](https://github.com/magemojo/m2-ce-cron) - Provides a cron service.


### Installation


```
git clone https://github.com/quantiota/magento-backup-rollback 
mkdir /srv/scripts/backup
cd magento-backup-rollback
mv backup.sh rollback.sh mailer.sh  /srv/scripts/backup
aws s3 mb s3://aws-magento-backup
```


## Usage:
### Default Variables:
Some default values are defined on the utility such as `backup location` and Magento `DocumentRoot`, Please change those variable according to your setup.
#### Backup variables
`MAGENTO_ROOT`  default value is  `/var/www/html/magento`

`BACKUP_PATH`               default value is `/var/www/html/magento/var/backups`

`AWS_BACKUP_DIR`            default value  is `aws-magento-backup`

`LOCAL_LIMIT_DAYS="+7"`     default value is `7` for `delete local backups older than 7 days`

`AWS_LIMIT_DAYS="+90"`      default value is `90` for `delete aws backups older than 90 days`

#### Amazon ses variables
`SENDER_DOMAIN`         default value is           `example.com`

`RECIPIENT_MAIL`        default value is           `recipient@example.com`                                                                                                           
`SENDER_MAIL`           default value is           `sender@example.com`                                                                                                           
`TMP_MAIL_FILE`         default value is           `/tmp/mail.txt`                                                                                                                                
`SES_USER_NAME`         default value is           `Base64EncodedSMTPUserName`                                                                                                     
`SES_PASS`              default value is           `Base64EncodedSMTPPassword`

`SES_ENDPOINT`          default value is           `email-smtp.us-west-2.amazonaws.com`

### Options
The `backup.sh` script accepts one option:

    -e : To specify the email notification enabled.

The `rollback.sh` script accepts three options:

    -f : To specify the archived files version to be restored.
    
    -d : To specify the archived database version to be restored.
    
    -a : To restore automatically the last archived files and database version.


### Email Notification

` Mail output of backup.sh as a notification                  `





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

### Schedule backup with cron
run backup at 3:00 am daily with email notification

`SHELL=/bin/sh`                                                                                       `PATH=/usr/local:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin`
` * 3 * * * /srv/scripts/backup.sh -e`

## License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
