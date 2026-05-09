-- credentials.sql
-- Sets up the security primitives required by Synapse Serverless SQL to talk
-- to the Azure Data Lake using Managed Identity authentication.
-- Run this once per database before creating external data sources or tables.

-- Create a master key for the database. Required by SQL Server / Synapse before
-- any database-scoped credentials can be created. The password is used to
-- encrypt the master key at rest; replace with a strong value in production.
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<StrongPassword>';

-- Create a database-scoped credential called "synapse_creds".
-- This credential tells Synapse to authenticate against the data lake using
-- the workspace's system-assigned Managed Identity, removing the need to
-- store any storage keys or connection secrets in the database.
IF NOT EXISTS (
    SELECT * FROM sys.database_scoped_credentials
    WHERE name = 'synapse_creds'
)
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL synapse_creds
    WITH IDENTITY = 'Managed Identity';
END;
