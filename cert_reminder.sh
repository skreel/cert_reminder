#!/bin/bash

# Configuration
CERT_PATH="/path/to/certificate.crt"  # Local certificate file
#CERT_URL="yourdomain.com:443"          # For remote certificate check
DAYS_WARNING=30                         # Days before expiration to trigger alert
EMAIL_TO="<email@example.com>"
EMAIL_FROM="<servername>"
SERVER_NAME="<servername.example.com>"

# healthchecks.io url
HEALTHCHECKS_URL="<https://hc-ping.com/guid>"

source cert_reminder.env

# Function to check expiration date
check_cert_expiry() 
{
    #echo $CERT_PATH
    if [ -f "$CERT_PATH" ]; then
        EXPIRATION_DATE=$(openssl x509 -enddate -noout -in "$CERT_PATH" | cut -d= -f2)
	#echo $EXPIRATION_DATE
#    else
#        EXPIRATION_DATE=$(echo | openssl s_client -connect "$CERT_URL" 2>/dev/null | openssl x509 -enddate -noout | cut -d= -f2)
    fi
    
    EXPIRATION_EPOCH=$(date -d "$EXPIRATION_DATE" +%s)
    CURRENT_EPOCH=$(date +%s)
    DIFF_DAYS=$(( (EXPIRATION_EPOCH - CURRENT_EPOCH) / 86400 ))
    
    if [ "$DIFF_DAYS" -le "$DAYS_WARNING" ]; then
        echo "WARNING: On ${SERVER_NAME} Certificate for $CERT_PATH expires in $DIFF_DAYS days!" | /usr/bin/mail -s "${SERVER_NAME} Certificate Expiration Warning" $EMAIL_TO -a "From: ${EMAIL_FROM}" <<< "WARNING: On ${SERVER_NAME} Certificate for $CERT_PATH expires in $DIFF_DAYS days!!"
    fi
}

# Run check
check_cert_expiry

## update heathchecks.io
## using curl (10 second timeout, retry up to 5 times):
curl -m 10 --retry 5 $HEALTHCHECKS_URL
