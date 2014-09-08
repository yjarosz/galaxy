#!/bin/bash
if [ "$1" == "daemon" ]; then
    supervisord --nodaemon
else
    supervisord && supervisorctl
fi
