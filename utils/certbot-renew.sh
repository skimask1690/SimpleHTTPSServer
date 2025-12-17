#!/bin/bash

if [[ " $* " == *" --dry-run "* ]]; then
    DRY_RUN="--dry-run"
fi

sudo certbot renew \
  --manual-auth-hook ./certbot-dynu-auth.sh \
  --manual-cleanup-hook ./certbot-dynu-cleanup.sh \
  $DRY_RUN
