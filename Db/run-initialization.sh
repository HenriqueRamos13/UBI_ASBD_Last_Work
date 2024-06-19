#!/usr/bin/env bash


# Wait for SQL Server to start
echo "Waiting for SQL Server to start..."
sleep 30s

# Echo to confirm script is running
echo "Starting database initialization..."

# Run SQL commands to create and initialize the database
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P password123! -d master -i create-database.sql

# Echo completion
echo "Database initialization completed."