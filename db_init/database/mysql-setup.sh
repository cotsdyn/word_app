#!/bin/bash
set -e  # exit immediately on error

mysql -u${DB_USERNAME} -p${DB_PASSWORD} -h${DB_HOSTNAME} < data.sql
