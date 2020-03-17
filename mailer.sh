#!/usr/bin/env bash

SENDER_DOMAIN="example.com"
RECIPIENT_MAIL="recipient@example.com"
SENDER_MAIL="sender@example.com"
TMP_MAIL_FILE="/tmp/mail1.txt"
SES_USER_NAME="Base64EncodedSMTPUserName"
SES_PASS="Base64EncodedSMTPPassword"
SES_ENDPOINT="email-smtp.us-west-2.amazonaws.com"

### Preparing MAIL Header
header () {
printf 'EHLO %s\n' $SENDER_DOMAIN
printf 'AUTH LOGIN\n'
printf '%s\n' $SES_USER_NAME
printf '%s\n' $SES_PASS
printf 'MAIL FROM: %s\n' $SENDER_MAIL
printf 'RCPT TO: %s\n' $RECIPIENT_MAIL
printf 'DATA\n'
printf 'From: Sender Name <%s>\n' $SENDER_MAIL
printf 'To: %s \n' $RECIPIENT_MAIL
printf 'Subject: Magento Backup Report for the date: %s\n' $date
}

### Preparing MAIL footer
footer () {
printf ".\nQUIT\n"
}

## Preparing Mail file
header > ${TMP_MAIL_FILE}
cat /tmp/mail.txt >> ${TMP_MAIL_FILE}
footer >>  ${TMP_MAIL_FILE}

## Sending Report Mail
echo "Sending Report Mail to $RECIPIENT_MAIL..."
openssl s_client -crlf -quiet -starttls smtp -connect ${SES_ENDPOINT}:587 < ${TMP_MAIL_FILE} > /dev/null 2>&1
echo ""
## Removing TMP_MAIL_FILE
echo "Cleaning up..."
rm -f ${TMP_MAIL_FILE}
