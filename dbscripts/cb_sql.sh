#!/bin/bash

# Database variables
DB_NAME="your_database"
DB_USER="your_user"
DB_PASSWORD="your_password"
DB_HOST="localhost"
DB_PORT="5432"

# Export password for non-interactive mode
export PGPASSWORD=$DB_PASSWORD

# SQL commands to create schema, table and insert data
SQL_COMMANDS=$(cat <<EOF
-- Create schema
CREATE SCHEMA IF NOT EXISTS my_schema;

-- Create table
CREATE TABLE IF NOT EXISTS my_schema.my_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    city VARCHAR(100)
);

-- Insert data
INSERT INTO my_schema.my_table (name, age, city)
VALUES 
    ('John Doe', 30, 'New York'),
    ('Jane Smith', 25, 'Los Angeles'),
    ('Mike Johnson', 40, 'Chicago');
EOF
)

# Execute SQL commands
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "$SQL_COMMANDS"

# Unset password
unset PGPASSWORD
