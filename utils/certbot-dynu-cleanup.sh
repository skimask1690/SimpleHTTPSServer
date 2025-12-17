#!/bin/bash
# certbot-dynu-cleanup.sh
# Cleanup hook for Certbot using Dynu API

API_KEY="YOUR_API_KEY_HERE"

DOMAIN_ID=$(curl -s "https://api.dynu.com/v2/dns" \
  -H "API-Key: $API_KEY" \
  | sed -n "s/.*\"id\":\([0-9]*\),\"name\":\"$CERTBOT_DOMAIN\".*/\1/p")

RECORD_ID=$(curl -s "https://api.dynu.com/v2/dns/$DOMAIN_ID/record" \
  -H "API-Key: $API_KEY" \
  | sed -n "s/.*\"id\":\([0-9]*\).*\"textData\":\"$CERTBOT_VALIDATION\".*/\1/p")

if [ -n "$RECORD_ID" ]; then
  curl -s -X DELETE "https://api.dynu.com/v2/dns/$DOMAIN_ID/record/$RECORD_ID" \
    -H "API-Key: $API_KEY"
fi