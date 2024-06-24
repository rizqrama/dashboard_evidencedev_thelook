select
    date_trunc('day', order_created_at) AS order_date,
    order_status,
    user_country AS country,
    product_category AS category,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(number_of_items) AS total_items,
    SUM(total_order_value) AS total_values,
    COUNT(DISTINCT user_id) AS total_unique_user,
    COUNT(DISTINCT product_id) AS total_unique_product
from thelook.df_orders
group by
    order_date,
    order_status,
    country,
    category
order by
    order_date,
    order_status,
    country,
    category