/* =========================================
   1. FCT_ORDER
========================================= */
USE DW_Project;
GO

IF OBJECT_ID('dbo.FCT_ORDER', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FCT_ORDER
    (
        order_fact_key INT IDENTITY(1,1) PRIMARY KEY,
        order_id NVARCHAR(50) NOT NULL,
        customer_key INT NOT NULL,
        order_detail_key INT NOT NULL,
        purchase_date_key INT NOT NULL,
        delivered_date_key INT NULL,
        waiting_day INT NULL,
        item_count INT NULL,
        order_value DECIMAL(18,2) NULL
    );
END;
GO


/* =========================================
   2. FCT_ORDER_REVIEW
========================================= */
IF OBJECT_ID('dbo.FCT_ORDER_REVIEW', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FCT_ORDER_REVIEW
    (
        order_review_fact_key INT IDENTITY(1,1) PRIMARY KEY,

        review_id NVARCHAR(50) NOT NULL,

        order_id NVARCHAR(50) NOT NULL,

        customer_key INT NOT NULL,

        review_score_key INT NOT NULL,

        review_creation_date_key INT NOT NULL,

        review_answer_date_key INT NULL,

        review_count INT NOT NULL DEFAULT 1,

        review_score INT NOT NULL,

        has_comment_message BIT NOT NULL DEFAULT 0,

        /* FK -> Customer */
        CONSTRAINT FK_FOR_Customer
            FOREIGN KEY (customer_key)
            REFERENCES dbo.DimCustomer(customer_key),

        /* FK -> Review Score */
        CONSTRAINT FK_FOR_ReviewScore
            FOREIGN KEY (review_score_key)
            REFERENCES dbo.DimReviewScore(review_score_key),

        /* FK -> Date (creation) */
        CONSTRAINT FK_FOR_CreationDate
            FOREIGN KEY (review_creation_date_key)
            REFERENCES dbo.DimDate(date_key),

        /* FK -> Date (answer) */
        CONSTRAINT FK_FOR_AnswerDate
            FOREIGN KEY (review_answer_date_key)
            REFERENCES dbo.DimDate(date_key)
    );
END;
GO

/* =========================================
   3. FCT_DAILY_ORDER_SNAPSHOT
========================================= */

IF OBJECT_ID('dbo.FCT_DAILY_ORDER_SNAPSHOT', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FCT_DAILY_ORDER_SNAPSHOT
    (
        snapshot_date_key INT PRIMARY KEY,

        total_orders_created INT NOT NULL DEFAULT 0,
        total_orders_approved INT NOT NULL DEFAULT 0,
        total_orders_delivered INT NOT NULL DEFAULT 0,
        total_orders_cancelled INT NOT NULL DEFAULT 0,
        total_revenue DECIMAL(18,2) NOT NULL DEFAULT 0,

        CONSTRAINT FK_FDOS_Date
            FOREIGN KEY (snapshot_date_key)
            REFERENCES dbo.DimDate(date_key)
    );
END;
GO
/* =========================================
   4. FCT_DAILY_SELLER_SNAPSHOT
========================================= */
IF OBJECT_ID('dbo.FCT_DAILY_SELLER_SNAPSHOT', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FCT_DAILY_SELLER_SNAPSHOT
    (
        snapshot_date_key INT NOT NULL,
        seller_key INT NOT NULL,
        orders_created_cnt INT NOT NULL DEFAULT 0,
        items_sold_cnt INT NOT NULL DEFAULT 0,
        total_revenue DECIMAL(18,2) NOT NULL DEFAULT 0,
        delivered_orders_cnt INT NOT NULL DEFAULT 0,
        cancelled_orders_cnt INT NOT NULL DEFAULT 0,
        avg_review_score DECIMAL(5,2) NULL,
        distinct_products_sold INT NOT NULL DEFAULT 0,

        /* Composite PK */
        CONSTRAINT PK_FCT_DAILY_SELLER_SNAPSHOT
            PRIMARY KEY (snapshot_date_key, seller_key),

        /* FK -> DimDate */
        CONSTRAINT FK_FDSS_Date
            FOREIGN KEY (snapshot_date_key)
            REFERENCES dbo.DimDate(date_key),

        /* FK -> DimSeller */
        CONSTRAINT FK_FDSS_Seller
            FOREIGN KEY (seller_key)
            REFERENCES dbo.DimSeller(seller_key)
    );
END;
GO

/* =========================================
   5. FCT_DAILY_PRODUCT_SNAPSHOT
========================================= */
IF OBJECT_ID('dbo.FCT_DAILY_PRODUCT_SNAPSHOT', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FCT_DAILY_PRODUCT_SNAPSHOT
    (
        snapshot_date_key INT NOT NULL,
        product_key INT NOT NULL,
        items_sold_cnt INT NOT NULL DEFAULT 0,
        total_revenue DECIMAL(18,2) NOT NULL DEFAULT 0,
        avg_review_score DECIMAL(5,2) NULL,

        CONSTRAINT PK_FCT_DAILY_PRODUCT_SNAPSHOT
            PRIMARY KEY (snapshot_date_key, product_key),

        CONSTRAINT FK_FDPS_Date
            FOREIGN KEY (snapshot_date_key)
            REFERENCES dbo.DimDate(date_key),

        CONSTRAINT FK_FDPS_Product
            FOREIGN KEY (product_key)
            REFERENCES dbo.DimProduct(product_key)
    );
END;
GO
/* =========================================
   6. FCT_CUSTOMER_BEHAVIOR_SNAPSHOT
========================================= */
IF OBJECT_ID('dbo.FCT_CUSTOMER_BEHAVIOR_SNAPSHOT', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FCT_CUSTOMER_BEHAVIOR_SNAPSHOT
    (
        customer_key INT NOT NULL PRIMARY KEY,
        avg_score_review DECIMAL(5,2) NULL,
        total_spend DECIMAL(18,2) NOT NULL DEFAULT 0,
        order_cnt INT NOT NULL DEFAULT 0,
        order_cancelled_cnt INT NOT NULL DEFAULT 0,
        avg_day_return_to_buy DECIMAL(10,2) NULL,

        CONSTRAINT FK_FCBS_Customer
            FOREIGN KEY (customer_key)
            REFERENCES dbo.DimCustomer(customer_key)
    );
END;
GO