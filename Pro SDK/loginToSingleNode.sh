#!/bin/bash
set -e
source $SERVER_CONFIG/data.cfg
if ([ ! -z "$1" ] && [ ! -z "$2" ]); then
    echo "Loging into $2 of cluster $1"
else
    echo "Supply cluster name and node IP as parameters"
   exit 1
fi


ssh -n -i ~/.ssh/$1 -o "StrictHostKeyChecking no" "$WN_USER@$2" "echo 2>&1" && echo "Can connect to $2" || echo "Can't connect to $2"
