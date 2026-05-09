-- openrowset_queries.sql
-- Ad-hoc query example using OPENROWSET against the Gold-layer Delta files.
-- This is the lightweight alternative to creating an external table: it lets
-- Synapse Serverless SQL read the Delta dataset directly from ADLS Gen2
-- without registering any persistent metadata objects.

-- Read the entire Delta dataset stored under gold/sales/ in the data lake.
-- BULK accepts the abfss-style HTTPS path of the container/folder and
-- FORMAT='DELTA' tells Synapse to honor the Delta transaction log when
-- resolving the current snapshot of the data.
SELECT *
FROM OPENROWSET(
    BULK 'https://<storage-account-name>.dfs.core.windows.net/gold/sales/',
    FORMAT = 'DELTA'
) AS sales_data;
