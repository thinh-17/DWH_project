USE DataWarehouse;
GO

/* =========================================
   1. FCT_ORDER
========================================= */
IF OBJECT_ID('dbo.FCT_ORDER', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FCT_ORDER
    (
        order_fact_key INT IDENTITY(1,1) PRIMARY KEY,
        order_id NVARCHAR(50) NOT NULL,

        customer_key INT NOT NULL,
        order_status_key INT NOT NULL,

        purchase_date_key INT NULL,
        delivered_carrier_date_key INT NULL,
        delivered_customer_date_key INT NULL,
        estimated_delivery_date_key INT NULL,

        item_count INT NULL,
        order_total_freight_value DECIMAL(18,2) NULL,
        order_total_amount DECIMAL(18,2) NULL,

        approval_lead_time_hours DECIMAL(18,2) NULL,
        delivery_lead_time_days DECIMAL(18,2) NULL,
        estimated_vs_actual_days DECIMAL(18,2) NULL,

        is_delivered BIT NULL,
        is_cancelled BIT NULL,
        is_late_delivery BIT NULL
    );
END;
GO

/* =========================================
   2. FCT_ORDER_ITEM
========================================= */
IF OBJECT_ID('dbo.FCT_ORDER_ITEM', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FCT_ORDER_ITEM
    (
        order_item_fact_key INT IDENTITY(1,1) PRIMARY KEY,

        order_id NVARCHAR(50) NOT NULL,
        order_item_id INT NOT NULL,

        customer_key INT NOT NULL,
        seller_key INT NOT NULL,
        product_key INT NOT NULL,
        order_status_key INT NOT NULL,

        purchase_date_key INT NULL,
        delivered_carrier_date_key INT NULL,
        delivered_customer_date_key INT NULL,
        estimated_delivery_date_key INT NULL,
        shipping_limit_date_key INT NULL,

        freight_value DECIMAL(18,2) NULL,
        gross_item_amount DECIMAL(18,2) NULL,

        item_count INT NULL,

        delivery_lead_time_days DECIMAL(18,2) NULL,
        estimated_vs_actual_days DECIMAL(18,2) NULL,

        is_delivered BIT NULL,
        is_cancelled BIT NULL,
        is_late_delivery BIT NULL
    );
END;
GO

/* =========================================
   3. FCT_ORDER_REVIEW
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

        review_creation_date_key INT NULL,
        review_answer_date_key INT NULL,

        review_count INT NULL,
        review_score DECIMAL(18,2) NULL,
        has_comment_message BIT NULL
    );
END;
GO

/* =========================================
   4. FCT_DAILY_ORDER_SNAPSHOT
========================================= */
IF OBJECT_ID('dbo.FCT_DAILY_ORDER_SNAPSHOT', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FCT_DAILY_ORDER_SNAPSHOT
    (
        snapshot_date_key INT PRIMARY KEY,

        total_orders_created INT NULL,
        total_orders_approved INT NULL,
        total_orders_delivered INT NULL,
        total_orders_cancelled INT NULL,

        total_revenue DECIMAL(18,2) NULL,
        total_freight_value DECIMAL(18,2) NULL,
        avg_order_value DECIMAL(18,2) NULL,

        avg_delivery_lead_time_days DECIMAL(18,2) NULL,
        avg_review_score DECIMAL(18,2) NULL,

        distinct_customers INT NULL,
        distinct_sellers INT NULL
    );
END;
GO

/* =========================================
   5. FCT_DAILY_SELLER_SNAPSHOT
========================================= */
IF OBJECT_ID('dbo.FCT_DAILY_SELLER_SNAPSHOT', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FCT_DAILY_SELLER_SNAPSHOT
    (
        snapshot_date_key INT NOT NULL,
        seller_key INT NOT NULL,

        orders_created_cnt INT NULL,
        items_sold_cnt INT NULL,
        gross_merchandise_value DECIMAL(18,2) NULL,

        delivered_orders_cnt INT NULL,
        cancelled_orders_cnt INT NULL,
        late_deliveries_cnt INT NULL,

        avg_delivery_days DECIMAL(18,2) NULL,
        avg_review_score DECIMAL(18,2) NULL,

        distinct_products_sold INT NULL,

        PRIMARY KEY (snapshot_date_key, seller_key)
    );
END;
GO

/* =========================================
   6. FCT_DAILY_PRODUCT_SNAPSHOT
========================================= */
IF OBJECT_ID('dbo.FCT_DAILY_PRODUCT_SNAPSHOT', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FCT_DAILY_PRODUCT_SNAPSHOT
    (
        snapshot_date_key INT NOT NULL,
        product_key INT NOT NULL,

        items_sold_cnt INT NULL,
        gross_sales_value DECIMAL(18,2) NULL,
        freight_value DECIMAL(18,2) NULL,
        total_revenue DECIMAL(18,2) NULL,

        avg_freight_value DECIMAL(18,2) NULL,
        late_delivery_cnt INT NULL,

        avg_delivery_days DECIMAL(18,2) NULL,
        avg_review_score DECIMAL(18,2) NULL,

        distinct_customers_cnt INT NULL,
        distinct_sellers_cnt INT NULL,

        PRIMARY KEY (snapshot_date_key, product_key)
    );
END;
GO