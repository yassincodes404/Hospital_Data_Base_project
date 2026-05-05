#!/bin/bash
# This script runs in the background and waits for MySQL to be ready,
# then executes the schema and seed scripts every time the container starts.

echo "Waiting for MySQL to start..."
until mysqladmin ping -h localhost -u root -p"${MYSQL_ROOT_PASSWORD}" --silent; do
    sleep 2
done

echo "MySQL is up. Running schema and seed scripts..."
# Use -f to continue even if there are errors (optional, but good for idempotency)
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" < /docker-entrypoint-initdb.d/1-schema.sql
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" < /docker-entrypoint-initdb.d/2-seed.sql

echo "Initialization scripts executed successfully."
