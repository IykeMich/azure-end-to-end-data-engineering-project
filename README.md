# Azure End-to-End Data Engineering Project

## Overview

This project demonstrates the design and implementation of an end-to-end Azure Data Engineering pipeline using Azure-native services.

The solution was built to simulate a modern cloud-based analytics platform capable of ingesting, transforming, storing, and exposing analytical data for downstream business intelligence and reporting use cases.

The architecture follows the **Medallion Data Architecture** pattern:

- **Raw Layer** → Stores ingested source data
- **Refined Layer** → Stores cleaned and transformed datasets
- **Gold Layer** → Stores business-ready curated data for analytics and reporting

---

# Architecture

```text
GitHub CSV Dataset
        ↓
Azure Synapse Pipeline (Copy Activity)
        ↓
Azure Data Lake Gen2 (Raw Layer)
        ↓
Synapse Data Flow / PySpark Transformations
        ↓
Azure Data Lake Gen2 (Refined Layer)
        ↓
PySpark Business Transformations
        ↓
Azure Data Lake Gen2 (Gold Layer - Delta Format)
        ↓
Serverless SQL Pool
        ↓
External Tables
        ↓
Power BI / Analytics Consumption
```

---

# Technologies Used

- Azure Resource Group
- Azure Data Lake Storage Gen2 (ADLS Gen2)
- Azure Synapse Analytics
- Azure Synapse Pipelines
- Azure Synapse Data Flows
- Apache Spark Pool
- PySpark
- Delta Lake
- Serverless SQL Pool
- OPENROWSET
- External Tables
- Azure IAM / RBAC
- Managed Identity Authentication

---

# Project Objectives

The major objectives of this project were to:

- Build a scalable cloud-native data pipeline
- Implement Medallion Architecture using Azure
- Orchestrate ETL/ELT workflows using Synapse
- Perform transformations using both Data Flow and Spark
- Store analytical datasets in Delta Lake format
- Expose curated datasets through external tables
- Enable future Power BI integration

---

# Resource Setup

## Resource Group

A centralized Azure Resource Group was created:

```text
Managed-RG-AzureDataEngineering
```

This was done to:

- Organize all project resources
- Simplify cost tracking
- Improve resource governance
- Apply consistent tagging strategy

---

# Azure Data Lake Storage Gen2

A storage account was created to serve as the project's Data Lake.

## Configuration

| Setting | Value |
|---|---|
| Storage Account | azuredatastoragelagos |
| Redundancy | LRS |
| Hierarchical Namespace | Enabled |

## Why Hierarchical Namespace Was Enabled

Hierarchical Namespace was enabled because:

- ADLS Gen2 requires it for big data workloads
- It supports folder/subfolder structures
- It improves analytical performance
- It enables Hadoop-compatible file operations

---

# Azure Synapse Analytics Workspace

An Azure Synapse Analytics workspace was created to orchestrate the complete data engineering workflow.

## Workspace Details

| Setting | Value |
|---|---|
| Workspace Name | azuresynapselagos |
| Default Data Lake | managedazurede |

## Why Synapse Was Used

Azure Synapse Analytics was selected because it provides:

- Pipeline orchestration
- Data transformation
- Apache Spark integration
- Serverless SQL querying
- Unified analytics capabilities

Synapse Pipelines are built on Azure Data Factory (ADF) technology, making Synapse a strong unified analytics platform for Azure-centric environments.

---

# Security & Access Management

## Managed Identity & RBAC

To allow Synapse securely communicate with the Data Lake, the following role assignment was configured:

```text
Storage Blob Data Contributor
```

This enabled secure:

- Read access
- Write access
- Delete access

without exposing storage keys or secrets.

---

# Linked Services

Two linked services were created within Synapse:

## 1. External Data Lake Linked Service

| Setting | Value |
|---|---|
| Name | externaldatalake |
| Authentication Type | System-assigned Managed Identity |

Purpose:
- Connect Synapse to ADLS Gen2 securely

---

## 2. GitHub HTTP Linked Service

| Setting | Value |
|---|---|
| Name | github |
| Base URL | https://raw.githubusercontent.com |
| Authentication | Anonymous |

Purpose:
- Pull raw CSV data directly from GitHub

---

# Data Ingestion Pipeline

A Synapse pipeline named:

```text
ApiToDataLake
```

was created for ingestion.

## Copy Activity

The pipeline contains a Copy Activity named:

```text
GithubToDataLake
```

This activity:

- Reads CSV data from GitHub
- Copies the dataset into the Raw Layer of ADLS Gen2
- Converts the dataset into Parquet format

## Source Dataset

```text
BigMartSales.csv
```

## Sink Format

```text
Parquet
```

## Why Parquet Was Used

Parquet was selected because it:

- Is columnar in nature
- Optimizes analytical queries
- Reduces storage cost
- Improves performance

Using the `.parquet` extension is also considered a best practice for readability and interoperability.

---

# Data Transformation (Refined Layer)

A new container named:

```text
refined
```

was created to store transformed datasets.

## Synapse Data Flow

A Mapping Data Flow was created to:

- Import schema
- Preview datasets
- Perform transformations
- Standardize the dataset structure

## Data Flow Debug

Data Flow Debug was enabled to:

- Preview transformed data
- Validate transformations
- Troubleshoot pipeline logic

## Sink Configuration

| Setting | Value |
|---|---|
| Dataset Type | Delta |
| Destination | refined/github/data |

---

# Apache Spark Transformations

An Apache Spark Pool named:

```text
sparkpool
```

was created to perform advanced transformations using PySpark.

## Purpose of Spark Usage

PySpark was used to:

- Perform scalable transformations
- Simulate distributed processing
- Create curated business-level datasets
- Generate the Gold Layer output

The transformed datasets were stored inside the Gold Layer in Delta format.

---

# Medallion Architecture

The project follows the Medallion Architecture pattern.

## Raw Layer

Stores:
- Original ingested source data

Characteristics:
- Minimal transformation
- Historical preservation

---

## Refined Layer

Stores:
- Cleaned and transformed datasets

Characteristics:
- Standardized schema
- Improved data quality

---

## Gold Layer

Stores:
- Curated business-ready datasets

Characteristics:
- Analytics-ready
- Reporting-friendly
- Optimized for BI workloads

---

# Querying Data Using OPENROWSET

OPENROWSET was used to directly query files stored inside the Data Lake.

## Why OPENROWSET Was Used

Data Lake files are stored in formats such as:

- CSV
- Parquet
- Delta

OPENROWSET allows Synapse Serverless SQL to query these files directly without physically loading them into relational tables.

---

# Metadata Layer & External Tables

To expose the Gold Layer as SQL-accessible tables, a metadata layer was implemented using:

- External Data Sources
- Database Scoped Credentials
- External File Formats
- External Tables

---

# Database Scoped Credential

A Master Key was first created to securely store authentication information.

```sql
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<StrongPassword>';
```

A Database Scoped Credential was then created using Managed Identity authentication.

## Benefits

- No hardcoded secrets
- Secure authentication
- Reusable deployment scripts

---

# External Data Source

An External Data Source named:

```text
gold_source
```

was created to connect Synapse SQL to:

```text
https://azuredatastoragelagos.dfs.core.windows.net/gold/
```

---

# External File Format

An External File Format named:

```text
delta_format
```

was created with:

```text
FORMAT_TYPE = DELTA
```

This allows Synapse to correctly interpret Delta Lake files.

---

# External Table Creation

An external schema named:

```text
gold
```

was created to organize curated datasets.

An external table named:

```text
gold.sales
```

was then created to expose analytical data stored in the Gold Layer.

## Benefits of External Tables

- SQL-based analytics access
- No physical data duplication
- Faster reporting integration
- Power BI compatibility

---

# Key Engineering Concepts Demonstrated

This project demonstrates practical understanding of:

- End-to-end ETL/ELT workflows
- Medallion Data Architecture
- Azure RBAC & Managed Identity
- Synapse Pipeline orchestration
- Mapping Data Flows
- Delta Lake implementation
- Distributed processing with Spark
- Serverless SQL querying
- Metadata-driven analytics architecture

---

# Challenges Faced

Some challenges encountered during the project included:

- Configuring RBAC permissions correctly
- Understanding Synapse linked service authentication
- Working with Delta format configuration
- Understanding interaction between Spark and ADLS Gen2
- Managing pipeline orchestration dependencies

---

# Lessons Learned

Through this project, I learned:

- How Azure services integrate into a complete analytics platform
- The importance of secure authentication using Managed Identity
- Differences between Data Flow and Spark transformations
- How Delta Lake improves modern analytics workloads
- How external tables simplify analytics access

---

# Future Improvements

Future improvements for this project include:

- CI/CD deployment using GitHub Actions
- Parameterized Synapse pipelines
- Incremental data loading
- Data quality validation checks
- Monitoring & alerting implementation
- Power BI dashboard integration
- Infrastructure as Code (Terraform/Bicep)

---

# Conclusion

This project provided hands-on experience in designing and implementing a modern cloud-based Azure Data Engineering solution using enterprise-level concepts and services.

It demonstrates the complete lifecycle of:

- Data ingestion
- Transformation
- Storage
- Querying
- Metadata management
- Analytics enablement

using Azure-native technologies.
