#!/usr/bin/env python
# coding: utf-8

# RefinedToGold
# This PySpark script reads cleaned data from the Refined layer of the data lake,
# performs business-level aggregations, and writes the curated output to the
# Gold layer in Delta format for downstream analytics and reporting.


# Import all PySpark SQL functions (sum, round, col, etc.) used for transformations.
from pyspark.sql.functions import *


# Read the refined dataset from Azure Data Lake Storage Gen2 in Delta format.
# The "abfss" scheme is the Azure Blob File System driver used by Spark to talk
# to ADLS Gen2 securely via the linked Managed Identity.
df = spark.read.format("delta") \
    .load("abfss://refined@<storage-account-name>.dfs.core.windows.net/github/data/")


# Display the raw refined dataset for visual inspection inside the Synapse notebook.
display(df)


# Aggregation
# Aggregate total sales by establishment year and outlet location type so we
# can later analyze sales performance across regions and store ages.
df = df.groupBy("Outlet_Establishment_Year", "Outlet_Location_Type") \
    .agg(sum("Item_Outlet_Sales").alias("total_sales"))

# Round the aggregated sales values to 2 decimal places for currency formatting.
df = df.withColumn("total_sales", round("total_sales", 2))

# Display the aggregated dataset for verification.
display(df)


# Sort the aggregated dataset by establishment year for easier inspection of
# yearly trends in total sales.
display(df.sort("Outlet_Establishment_Year"))


# Persist the curated Gold-layer dataset back to ADLS Gen2 in Delta format.
# Overwrite mode ensures that each pipeline run produces a fresh, fully
# refreshed Gold dataset, which is consumed by Serverless SQL external tables.
df.write.format("delta") \
    .mode("Overwrite") \
    .option("path", "abfss://gold@<storage-account-name>.dfs.core.windows.net/github/data/") \
    .save()
