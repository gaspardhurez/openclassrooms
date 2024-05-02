/* Requête 1 */

SELECT 
        *,
        ROUND(julianday(date('now')) - julianday(order_purchase_timestamp), 0) AS command_recency,
        ROUND(julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date), 0) AS command_lateness
FROM orders
WHERE order_status != ('canceled')
AND julianday(date('now')) - julianday(order_purchase_timestamp) < 90
AND julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date) > 3
;

/* Requête 2 */
SELECT 
        seller_id,
        SUM(order_item_id * price + order_item_id * freight_value) AS turnover
FROM order_items
GROUP BY seller_id
HAVING turnover >= 100000
ORDER BY turnover DESC
;

/* Requête 3 */
/* Si produits vendus = produits uniques */
SELECT 
        a.seller_id,
        COUNT(product_id) AS products_sold,
        MIN(b.order_purchase_timestamp) AS first_sale_date
FROM order_items AS a
LEFT JOIN orders AS b USING(order_id)
GROUP BY seller_id
HAVING COUNT(product_id) > 30 AND julianday(date('now')) - julianday(MIN(b.order_purchase_timestamp)) < 90
;

/* Si produits vendus = quantité totale de produits vendus */
SELECT 
        a.seller_id,
        SUM(order_item_id) AS products_sold,
        MIN(b.order_purchase_timestamp) AS first_sale_date
FROM order_items AS a
LEFT JOIN orders AS b USING(order_id)
GROUP BY a.seller_id
HAVING products_sold > 30 AND julianday(date('now')) - julianday(MIN(b.order_purchase_timestamp)) < 90
;

/* Requête 4 */
SELECT 
        b.customer_zip_code_prefix,
        COUNT(order_id) AS number_of_orders,
        ROUND(AVG(c.review_score), 2) AS mean_review_score
FROM orders AS a 
LEFT JOIN customers AS b USING(customer_id)
LEFT JOIN order_reviews AS c USING(order_id)
WHERE julianday(date('now')) - julianday(order_purchase_timestamp) < 3000
GROUP BY b.customer_zip_code_prefix
HAVING COUNT(order_id) >= 30
ORDER BY mean_review_score ASC
LIMIT 5;

/* Réalisé et executé avec la syntaxe SQLite */