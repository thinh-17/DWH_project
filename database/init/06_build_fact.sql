-- ============================================
-- 1 Fact Order
-- detail: giữ waiting_day để null thay vì đánh dấu 0, vì có thể có những đơn hàng chưa được giao nên không thể tính waiting_day 
-- ============================================
SELECT
    dod.order_id,
    dod.customer_key,
    dod.purchase_date_key,
    dod.delivered_date_key,
    dod.order_detail_key,

    DATEDIFF(
        DAY,
        dd_purchase.full_date,
        dd_delivered.full_date
    ) AS waiting_day,

    ISNULL(oi.item_count, 0) AS item_count,
    ISNULL(op.total_payment_value, 0) AS order_value

FROM dbo.DimOrderDetail dod

LEFT JOIN dbo.DimDate dd_purchase
    ON dod.purchase_date_key = dd_purchase.date_key

LEFT JOIN dbo.DimDate dd_delivered
    ON dod.delivered_date_key = dd_delivered.date_key

LEFT JOIN
(
    SELECT
        order_id,
        COUNT(DISTINCT order_item_id) AS item_count
    FROM stg.order_items
    GROUP BY order_id
) oi
    ON dod.order_id = oi.order_id

LEFT JOIN
(
    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value
    FROM stg.order_payments
    GROUP BY order_id
) op
    ON dod.order_id = op.order_id;
-- ============================================
-- 2 Fact Order Reviews
-- detail: check thuộc tính lấy từ staging
-- ============================================
SELECT
    r.review_id,

    r.order_id,

    fo.customer_key,

    drs.review_score_key,

    dd_creation.date_key AS review_creation_date_key,

    dd_answer.date_key AS review_answer_date_key,

    1 AS review_count,

    r.review_score AS review_score,

    CASE
        WHEN r.review_comment_message IS NOT NULL
             AND LTRIM(RTRIM(r.review_comment_message)) <> ''
        THEN 1
        ELSE 0
    END AS has_comment_message

FROM stg.order_reviews r

/* =========================
   CUSTOMER lấy từ FACT ORDER
========================= */
LEFT JOIN dbo.FCT_ORDER fo
    ON r.order_id = fo.order_id

/* =========================
   REVIEW SCORE từ DIM
========================= */
LEFT JOIN dbo.DimReviewScore drs
    ON r.review_score = drs.review_score

/* =========================
   DATE DIM
========================= */
LEFT JOIN dbo.DimDate dd_creation
    ON CAST(CONVERT(VARCHAR(8), r.review_creation_date, 112) AS INT)
       = dd_creation.date_key

LEFT JOIN dbo.DimDate dd_answer
    ON CAST(CONVERT(VARCHAR(8), r.review_answer_timestamp, 112) AS INT)
       = dd_answer.date_key;

-- ============================================
-- 3 Fact Daily Order Snapshot
-- detail: snapshot hàng ngày, mỗi ngày có một bản ghi tổng hợp số lượng order, doanh thu, ... (sạch không thêm check)
-- ============================================
SELECT
    dd.date_key AS snapshot_date_key,

    /* tổng số order tạo trong ngày */
    COUNT(fo.order_id) AS total_orders_created,

    /* tổng số order delivered */
    SUM(
        CASE
            WHEN dod.order_status = 'delivered' THEN 1
            ELSE 0
        END
    ) AS total_orders_delivered,

    /* tổng số order cancelled */
    SUM(
        CASE
            WHEN dod.order_status IN ('canceled', 'cancelled') THEN 1
            ELSE 0
        END
    ) AS total_orders_cancelled,

    /* tổng doanh thu */
    ISNULL(SUM(fo.order_value), 0) AS total_revenue


FROM dbo.DimDate dd

LEFT JOIN dbo.DimOrderDetail dod
    ON dod.purchase_date_key = dd.date_key

LEFT JOIN dbo.FCT_ORDER fo
    ON dod.order_id = fo.order_id

GROUP BY dd.date_key

ORDER BY dd.date_key;
--============================================
-- 4 Fact Daily Product Snapshot
-- detail: snapshot hàng ngày theo sản phẩm, mỗi ngày có một bản ghi tổng hợp số lượng bán ra, doanh thu, ... ISNULL(oi.price, 0)  
--============================================
SELECT
    dd.date_key AS snapshot_date_key,
    dp.product_key,
    COUNT(oi.price) AS items_sold_cnt,
    CAST(SUM(ISNULL(oi.price, 0)) AS DECIMAL(18,2)) AS total_revenue,
    CAST(AVG(rv.review_score) AS DECIMAL(5,2)) AS avg_review_score
FROM stg.order_items oi
INNER JOIN stg.orders o
    ON oi.order_id = o.order_id
INNER JOIN dbo.DimProduct dp
    ON oi.product_id = dp.product_id
    AND dp.version = 1
INNER JOIN dbo.DimDate dd
    ON CAST(CONVERT(VARCHAR(8), o.order_purchase_timestamp, 112) AS INT)
       = dd.date_key
LEFT JOIN
(
    SELECT
        order_id,
        AVG(CAST(review_score AS FLOAT)) AS review_score
    FROM dbo.FCT_ORDER_REVIEW
    GROUP BY order_id
) rv
    ON oi.order_id = rv.order_id
GROUP BY
    dd.date_key,
    dp.product_key
--============================================
-- 5 Fact Daily Seller Snapshot 
-- detail: snapshot hàng ngày theo seller
--============================================
SELECT
    ISNULL(dd.date_key, -1) AS snapshot_date_key,
    ISNULL(ds.seller_key, -1) AS seller_key,
    -- số order tạo
    COUNT(DISTINCT oi.order_id) AS orders_created_cnt,

    -- tổng số item bán
    COUNT(*) AS items_sold_cnt,

    -- tổng doanh thu
    CAST(SUM(ISNULL(oi.price, 0)) AS DECIMAL(18,2)) AS total_revenue,

    -- số order delivered
    COUNT(DISTINCT CASE
        WHEN LOWER(o.order_status) = 'delivered'
        THEN oi.order_id
    END) AS delivered_orders_cnt,

    -- số order cancelled
    COUNT(DISTINCT CASE
        WHEN LOWER(o.order_status) IN ('canceled', 'cancelled')
        THEN oi.order_id
    END) AS cancelled_orders_cnt,

    -- điểm review trung bình (đã fix double count)
    CAST(AVG(rv.review_score) AS DECIMAL(5,2)) AS avg_review_score,

    -- số sản phẩm khác nhau bán
    COUNT(DISTINCT oi.product_id) AS distinct_products_sold

FROM stg.order_items oi

/* =========================
   ORDER (nên INNER JOIN)
========================= */
INNER JOIN stg.orders o
    ON oi.order_id = o.order_id

/* =========================
   REVIEW (PRE-AGG để tránh nhân dòng)
========================= */
LEFT JOIN
(
    SELECT
        order_id,
        AVG(CAST(review_score AS FLOAT)) AS review_score
    FROM stg.order_reviews
    GROUP BY order_id
) rv
    ON oi.order_id = rv.order_id

/* =========================
   DIM SELLER
========================= */
LEFT JOIN dbo.DimSeller ds
    ON oi.seller_id = ds.seller_id
    AND ds.version = 1

/* =========================
   DIM DATE
========================= */
LEFT JOIN dbo.DimDate dd
    ON CAST(CONVERT(VARCHAR(8), o.order_purchase_timestamp, 112) AS INT)
       = dd.date_key

/* =========================
   GROUP BY
========================= */
GROUP BY
    ISNULL(dd.date_key, -1),
    ISNULL(ds.seller_key, -1)

/* =========================
   ORDER
========================= */
ORDER BY
    snapshot_date_key,
    seller_key;
-- ============================================
-- 6 Fact Customer behavior snapshot    
-- detail: snapshot hàng ngày theo customer, mỗi ngày có một bản ghi tổng hợp số lượng order, doanh thu, ... (sạch không thêm check)
-- ============================================
SELECT
    fo.customer_key,

    AVG(CAST(fr.review_score AS FLOAT)) AS avg_score_review,

    SUM(ISNULL(fo.order_value, 0)) AS total_spend,

    COUNT(DISTINCT fo.order_id) AS order_cnt,

    COUNT(DISTINCT CASE
        WHEN dod.order_status IN ('canceled', 'cancelled')
        THEN fo.order_id
    END) AS order_cancelled_cnt,

    rd.avg_day_return_to_buy

FROM dbo.FCT_ORDER fo

LEFT JOIN dbo.DimOrderDetail dod
    ON fo.order_detail_key = dod.order_detail_key

LEFT JOIN dbo.FCT_ORDER_REVIEW fr
    ON fo.order_id = fr.order_id

LEFT JOIN
(
    SELECT
        x.customer_key,
        AVG(CAST(x.days_between_orders AS FLOAT)) AS avg_day_return_to_buy
    FROM
    (
        SELECT
            fo.customer_key,
            DATEDIFF(
                DAY,
                LAG(dd.full_date) OVER (
                    PARTITION BY fo.customer_key
                    ORDER BY dd.full_date
                ),
                dd.full_date
            ) AS days_between_orders
        FROM dbo.FCT_ORDER fo
        LEFT JOIN dbo.DimOrderDetail dod
            ON fo.order_detail_key = dod.order_detail_key
        LEFT JOIN dbo.DimDate dd
            ON dod.purchase_date_key = dd.date_key
    ) x
    GROUP BY x.customer_key
) rd
    ON fo.customer_key = rd.customer_key

GROUP BY
    fo.customer_key,
    rd.avg_day_return_to_buy;