#!/bin/bash

if [[ " $* " == *" --dry-run "* ]]; then
    DRY_RUN="--dry-run"
fi

sudo certbot renew \
  --manual-auth-hook /etc/letsencrypt/certbot-dynu-auth.sh \
  --manual-cleanup-hook /etc/letsencrypt/certbot-dynu-cleanup.sh \
  $DRY_RUN