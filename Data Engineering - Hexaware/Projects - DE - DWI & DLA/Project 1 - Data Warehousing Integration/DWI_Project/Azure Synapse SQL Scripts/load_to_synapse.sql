---------------------------------------------------
-- STEP 0: Create a dedicated database
---------------------------------------------------
CREATE DATABASE DWI_Project;
GO

USE DWI_Project;
GO

---------------------------------------------------
-- STEP 1: Create Master Key (needed for credential)
---------------------------------------------------
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'StrongPassword@123!';
GO

---------------------------------------------------
-- STEP 2: Create Database Scoped Credential with SAS
-- (Paste only the SAS token part, WITHOUT '?')
---------------------------------------------------
-- Drop & recreate the credential (to be sure)
IF EXISTS (SELECT * FROM sys.database_scoped_credentials WHERE name = 'BlobSAS')
    DROP DATABASE SCOPED CREDENTIAL BlobSAS;

CREATE DATABASE SCOPED CREDENTIAL BlobSAS
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
     SECRET = 'sv=2024-11-04&ss=b&srt=sco&sp=rwdlacyx&se=2025-09-30T16:41:55Z&st=2025-08-26T08:26:55Z&spr=https&sig=zX0%2B1IshG4Ltspi00A2DIUVEgcU7iscriba6X%2Frae9o%3D';

---------------------------------------------------
-- STEP 3: Create External Data Source
---------------------------------------------------
IF EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'dwi_curated')
    DROP EXTERNAL DATA SOURCE dwi_curated;

CREATE EXTERNAL DATA SOURCE dwi_curated
WITH (
    LOCATION = 'https://hexdatastoragegen2.blob.core.windows.net/synapse',
    CREDENTIAL = BlobSAS
);

---------------------------------------------------
-- STEP 4: Create External File Format
---------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'ParquetFileFormat')
BEGIN
    CREATE EXTERNAL FILE FORMAT ParquetFileFormat
    WITH (FORMAT_TYPE = PARQUET);
END
GO

---------------------------------------------------
-- STEP 5: DROP OLD TABLES (avoid mismatch)
---------------------------------------------------
IF OBJECT_ID('dbo.fact_sales', 'U') IS NOT NULL DROP EXTERNAL TABLE dbo.fact_sales;
IF OBJECT_ID('dbo.dim_customer', 'U') IS NOT NULL DROP EXTERNAL TABLE dbo.dim_customer;
IF OBJECT_ID('dbo.dim_product', 'U') IS NOT NULL DROP EXTERNAL TABLE dbo.dim_product;
IF OBJECT_ID('dbo.dim_date', 'U') IS NOT NULL DROP EXTERNAL TABLE dbo.dim_date;
GO

---------------------------------------------------
-- STEP 6: CREATE EXTERNAL TABLES
---------------------------------------------------

-- Customer Dimension
CREATE EXTERNAL TABLE dbo.dim_customer (
    Customer_ID NVARCHAR(50),
    Gender NVARCHAR(10),
    Age INT
)
WITH (
    LOCATION = 'curated/dim_customer/',
    DATA_SOURCE = dwi_curated,
    FILE_FORMAT = ParquetFileFormat
);

-- Product Dimension
CREATE EXTERNAL TABLE dbo.dim_product (
    Product_Category NVARCHAR(100),
    Product_ID BIGINT  -- changed from INT
)
WITH (
    LOCATION = 'curated/dim_product/',
    DATA_SOURCE = dwi_curated,
    FILE_FORMAT = ParquetFileFormat
);

-- Date Dimension
CREATE EXTERNAL TABLE dbo.dim_date (
    Date_ID INT,
    Date DATE,
    Year INT,
    Month INT,
    Day INT,
    Quarter INT,
    WeekOfYear INT,
    DayOfWeek INT
)
WITH (
    LOCATION = 'curated/dim_date/',
    DATA_SOURCE = dwi_curated,
    FILE_FORMAT = ParquetFileFormat
);

-- Fact Table
CREATE EXTERNAL TABLE dbo.fact_sales (
    Transaction_ID INT,
    Date_ID INT,
    Customer_ID NVARCHAR(50),
    Product_ID BIGINT,
    Quantity INT,
    Price_per_Unit INT,
    Total_Amount INT
)
WITH (
    LOCATION = 'curated/fact_sales/',
    DATA_SOURCE = dwi_curated,
    FILE_FORMAT = ParquetFileFormat
);


---------------------------------------------------
-- STEP 7: Validation Queries
---------------------------------------------------

-- Direct queries
SELECT TOP 10 * FROM dbo.fact_sales;
SELECT TOP 10 * FROM dbo.dim_customer;
SELECT TOP 10 * FROM dbo.dim_product;
SELECT TOP 10 * FROM dbo.dim_date;





