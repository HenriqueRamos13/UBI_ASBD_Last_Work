#!/usr/bin/env bash


echo "Running entrypoint script..."
sh /usr/src/app/run-initialization.sh & /opt/mssql/bin/sqlservr