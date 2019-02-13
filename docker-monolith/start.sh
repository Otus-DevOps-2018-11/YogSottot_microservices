#!/usr/bin/env bash

/usr/bin/mongod --fork --config /etc/mongod.conf

source /reddit/db_config

cd /reddit && puma || exit
