USE DW_Project;
GO

/* =========================================
   1. DimDate
========================================= */
IF OBJECT_ID('dbo.DimDate', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimDate
    (
        date_key INT PRIMARY KEY,
        full_date DATE NOT NULL,
        day_of_month INT NOT NULL,
        month_num INT NOT NULL,
        month_name NVARCHAR(20) NOT NULL,
        quarter_num INT NOT NULL,
        year_num INT NOT NULL
    );
END;
GO

/* =========================================
   2. DimLocation
========================================= */
IF OBJECT_ID('dbo.DimLocation', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimLocation
    (
        location_key NVARCHAR(110) PRIMARY KEY,
        city NVARCHAR(100) NULL,
        state NVARCHAR(10) NULL
    );
END;
GO

/* =========================================
   3. DimCustomer
========================================= */
IF OBJECT_ID('dbo.DimCustomer', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimCustomer
    (
        customer_key INT IDENTITY(1,1) PRIMARY KEY,
        customer_id NVARCHAR(50) NOT NULL,
        customer_location_key NVARCHAR(110) NOT NULL,
        version INT NOT NULL
    );
END;
GO

/* =========================================
   4. DimSeller
========================================= */
IF OBJECT_ID('dbo.DimSeller', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimSeller
    (
        seller_key INT IDENTITY(1,1) PRIMARY KEY,
        seller_id NVARCHAR(50) NOT NULL,
        seller_location_key NVARCHAR(110) NOT NULL,
        version INT NOT NULL
    );
END;
GO

/* =========================================
   5. DimProduct
========================================= */
IF OBJECT_ID('dbo.DimProduct', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimProduct
    (
        product_key INT IDENTITY(1,1) PRIMARY KEY,
        product_id NVARCHAR(50) NOT NULL,
        product_category_name_english NVARCHAR(200) NULL,
        product_description_length INT NULL,
        product_price DECIMAL(18,2) NULL,
        version INT NOT NULL
    );
END;
GO

/* =========================================
   6. DimOrderStatus
========================================= */
IF OBJECT_ID('dbo.DimOrderStatus', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimOrderStatus
    (
        order_status_key INT IDENTITY(1,1) PRIMARY KEY,
        order_status NVARCHAR(50) NOT NULL

    );
END;
GO

/* =========================================
   7. DimReviewScore
========================================= */
IF OBJECT_ID('dbo.DimReviewScore', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DimReviewScore
    (
        review_score_key INT IDENTITY(1,1) PRIMARY KEY,
        review_score INT NOT NULL,
        score_label NVARCHAR(50) NULL
    );
END;
GO