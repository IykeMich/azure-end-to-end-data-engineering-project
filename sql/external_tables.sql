-- external_tables.sql
-- Builds the metadata layer that exposes the Gold-layer Delta files as a
-- queryable SQL surface. Creates the "gold" schema, registers the Delta
-- file format, and defines the gold.sales external table on top of the
-- curated dataset produced by the PySpark RefinedToGold notebook.

-- Create the "gold" schema if it does not already exist.
-- This schema groups all curated, business-ready external tables together
-- so analysts and BI tools can discover them in one logical namespace.
IF NOT EXISTS (
    SELECT * FROM sys.schemas
    WHERE name = 'gold'
)
BEGIN
    EXEC('CREATE SCHEMA gold');
END;

-- Register the Delta external file format.
-- This tells Synapse Serverless SQL how to interpret the underlying files
-- (transaction log + Parquet snapshots) when querying the external table.
IF NOT EXISTS (
    SELECT * FROM sys.external_file_formats
    WHERE name = 'delta_format'
)
BEGIN
    CREATE EXTERNAL FILE FORMAT delta_format
    WITH (
        FORMAT_TYPE = DELTA
    );
END;

-- Create the gold.sales external table over the Gold-layer "sales" folder.
-- The schema mirrors the aggregated dataset produced by the Spark job:
-- sales totals grouped by establishment year and outlet location type.
IF NOT EXISTS (
    SELECT * FROM sys.external_tables
    WHERE name = 'sales'
)
BEGIN
    CREATE EXTERNAL TABLE gold.sales
    (
        Outlet_Establishment_Year INT,
        Outlet_Location_Type VARCHAR(100),
        total_sales DECIMAL(15,2)
    )
    WITH
    (
        LOCATION = 'sales',
        DATA_SOURCE = gold_source,
        FILE_FORMAT = delta_format
    );
END;
