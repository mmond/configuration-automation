#!/bin/sh

/var/www/eldorado/current/script/process/spawner \
  mongrel \
  --environment=production \
  --instances=2 \
  --address=127.0.0.1 \
  --port=80