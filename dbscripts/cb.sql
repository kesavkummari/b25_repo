-- Create schema
CREATE SCHEMA IF NOT EXISTS my_schema;

-- Create table
CREATE TABLE IF NOT EXISTS my_schema.my_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    city VARCHAR(100)
);

-- Insert data into the table
INSERT INTO my_schema.my_table (name, age, city)
VALUES 
    ('John Doe', 30, 'New York'),
    ('Jane Smith', 25, 'Los Angeles'),
    ('Mike Johnson', 40, 'Chicago');


# mysql -h localhost -u your_user -p your_database < cb.sql
