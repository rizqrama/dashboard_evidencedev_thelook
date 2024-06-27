---
title: Product Sales Report
queries:
  - dm_agg_daily: dm_agg_daily.sql
  - dm_country_prodcat_daily: dm_country_prodcat_daily.sql
---

<DateRange
    name=daterange_filter_e
    data={dm_country_prodcat_daily}
    dates=order_date
/>

```sql dm_country_prodcat_daily_filtered
select *
from ${dm_country_prodcat_daily}
where
    order_date between '${inputs.daterange_filter_e.start}' and '${inputs.daterange_filter_e.end}'
```
```sql product_agg_sales
select
    category,
    sum(total_values) as p_total_values,
    sum(total_orders) as p_total_orders,
    sum(total_items) as p_total_items
FROM
    ${dm_country_prodcat_daily_filtered}
where order_status = 'Complete'
Group by category
```

## Products Sold over Time

Select a product category to analyze: <Dropdown data={product_agg_sales} name=dd_category value=category defaultValue = "Accessories" order=category> </Dropdown>

```sql product_sales_daily_cat
select
    order_date,
    category,
    sum(total_values) as p_total_values,
    sum(total_orders) as p_total_orders,
    sum(total_items) as p_total_items
FROM
    ${dm_country_prodcat_daily_filtered}
where
    order_status = 'Complete'
    and category = '${inputs.dd_category.value}'
Group by order_date, category
```
<center>
<CalendarHeatmap 
    data={product_sales_daily_cat}
    date=order_date
    value=p_total_items
    title="Number of Items Sold Daily"
    subtitle="{inputs.dd_category.label}"
/>
</center>








