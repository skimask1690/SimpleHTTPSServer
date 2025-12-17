#!/bin/bash
# certbot-dynu-auth.sh
# Auth hook for Certbot using Dynu API

API_KEY="YOUR_API_KEY_HERE"

DOMAIN_ID=$(curl -s "https://api.dynu.com/v2/dns" \
  -H "API-Key: $API_KEY" \
  | sed -n "s/.*\"id\":\([0-9]*\),\"name\":\"$CERTBOT_DOMAIN\".*/\1/p")

if [ -n "$DOMAIN_ID" ]; then
  curl -s "https://api.dynu.com/v2/dns/$DOMAIN_ID/record" \
    -H "API-Key: $API_KEY" \
    -d '{
      "textData": "'"$CERTBOT_VALIDATION"'",
      "domainName": "'"$CERTBOT_DOMAIN"'",
      "nodeName": "_acme-challenge",
      "recordType": "TXT",
      "ttl": 60,
      "state": true
    }' &&
  sleep 60
fi