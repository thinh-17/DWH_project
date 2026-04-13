USE DW_Project;
GO

IF OBJECT_ID('stg.orders', 'U') IS NOT NULL
    DROP TABLE stg.orders;
GO
CREATE TABLE stg.orders (
    order_id NVARCHAR(50) NULL,
    customer_id NVARCHAR(50) NULL,
    order_status NVARCHAR(50) NULL,
    order_purchase_timestamp DATETIME2 NULL,
    order_approved_at DATETIME2 NULL,
    order_delivered_carrier_date DATETIME2 NULL,
    order_delivered_customer_date DATETIME2 NULL,
    order_estimated_delivery_date DATETIME2 NULL
);
GO

IF OBJECT_ID('stg.order_items', 'U') IS NOT NULL
    DROP TABLE stg.order_items;
GO
CREATE TABLE stg.order_items (
    order_id NVARCHAR(50) NULL,
    order_item_id INT NULL,
    product_id NVARCHAR(50) NULL,
    seller_id NVARCHAR(50) NULL,
    shipping_limit_date DATETIME2 NULL,
    price DECIMAL(18,2) NULL,
    freight_value DECIMAL(18,2) NULL
);
GO

IF OBJECT_ID('stg.order_payments', 'U') IS NOT NULL
    DROP TABLE stg.order_payments;
GO
CREATE TABLE stg.order_payments (
    order_id NVARCHAR(50) NULL,
    payment_sequential INT NULL,
    payment_type NVARCHAR(50) NULL,
    payment_installments INT NULL,
    payment_value DECIMAL(18,2) NULL
);
GO

IF OBJECT_ID('stg.order_reviews', 'U') IS NOT NULL
    DROP TABLE stg.order_reviews;
GO
CREATE TABLE stg.order_reviews (
    review_id NVARCHAR(50) NULL,
    order_id NVARCHAR(50) NULL,
    review_score INT NULL,
    review_comment_title NVARCHAR(255) NULL,
    review_comment_message NVARCHAR(MAX) NULL,
    review_creation_date DATETIME2 NULL,
    review_answer_timestamp DATETIME2 NULL
);
GO

IF OBJECT_ID('stg.products', 'U') IS NOT NULL
    DROP TABLE stg.products;
GO
CREATE TABLE stg.products (
    product_id NVARCHAR(50) NULL,
    product_category_name NVARCHAR(255) NULL,
    product_name_lenght INT NULL,
    product_description_lenght INT NULL,
    product_photos_qty INT NULL,
    product_weight_g DECIMAL(18,2) NULL,
    product_length_cm DECIMAL(18,2) NULL,
    product_height_cm DECIMAL(18,2) NULL,
    product_width_cm DECIMAL(18,2) NULL
);
GO

IF OBJECT_ID('stg.customers', 'U') IS NOT NULL
    DROP TABLE stg.customers;
GO
CREATE TABLE stg.customers (
    customer_id NVARCHAR(50) NULL,
    customer_unique_id NVARCHAR(50) NULL,
    customer_zip_code_prefix NVARCHAR(20) NULL,
    customer_city NVARCHAR(100) NULL,
    customer_state NVARCHAR(10) NULL
);
GO

IF OBJECT_ID('stg.sellers', 'U') IS NOT NULL
    DROP TABLE stg.sellers;
GO
CREATE TABLE stg.sellers (
    seller_id NVARCHAR(50) NULL,
    seller_zip_code_prefix NVARCHAR(20) NULL,
    seller_city NVARCHAR(100) NULL,
    seller_state NVARCHAR(10) NULL
);
GO

IF OBJECT_ID('stg.geolocation', 'U') IS NOT NULL DROP TABLE stg.geolocation;
CREATE TABLE stg.geolocation (
    geolocation_zip_code_prefix NVARCHAR(20) NULL,
    geolocation_lat DECIMAL(18,10) NULL,
    geolocation_lng DECIMAL(18,10) NULL,
    geolocation_city NVARCHAR(100) NULL,
    geolocation_state NVARCHAR(10) NULL
);
GO

IF OBJECT_ID('stg.product_category_name_translation', 'U') IS NOT NULL DROP TABLE stg.product_category_name_translation;
CREATE TABLE stg.product_category_name_translation (
    product_category_name NVARCHAR(255) NULL,
    product_category_name_english NVARCHAR(255) NULL
);
GO
   