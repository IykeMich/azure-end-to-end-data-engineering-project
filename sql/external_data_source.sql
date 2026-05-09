-- external_data_source.sql
-- Registers the Gold-layer container in ADLS Gen2 as an external data source
-- inside Synapse Serverless SQL, so external tables can read Delta files
-- directly from the data lake without copying the data into a database.

-- Create the external data source "gold_source" pointing at the gold/ container.
-- It uses the previously-created "synapse_creds" database-scoped credential,
-- which authenticates with Managed Identity (no secrets are persisted here).
IF NOT EXISTS (
    SELECT * FROM sys.external_data_sources
    WHERE name = 'gold_source'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE gold_source
    WITH (
        LOCATION = 'https://<storage-account-name>.dfs.core.windows.net/gold/',
        CREDENTIAL = synapse_creds
    );
END;
