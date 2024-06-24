---
title: The Look eCommerce Sales Report
queries:
  - dm_agg_daily: dm_agg_daily.sql
  - dm_country_prodcat_daily: dm_country_prodcat_daily.sql
---

# Executive Summary

<DateRange
    name=daterange_filter_a
    data={dm_agg_daily}
    dates=order_date
/>

```sql dm_agg_daily_filtered
select
  *
from
  ${dm_agg_daily}
where
  order_date between '${inputs.daterange_filter_a.start}' and '${inputs.daterange_filter_a.end}'
```

```sql dm_country_prodcat_daily_filtered
select
  *
from
  ${dm_country_prodcat_daily}
where
  order_date between '${inputs.daterange_filter_a.start}' and '${inputs.daterange_filter_a.end}'
```

```sql agg_sales_yearly_cum_growth

with dm_agg_yearly as (
  select
    date_trunc('year', order_date) as order_year,
    order_status,
    SUM(total_orders) AS y_total_orders,
    SUM(total_values) AS y_total_values,
    SUM(total_items) AS y_total_items
from
  ${dm_agg_daily_filtered}
group by
  order_year,
  order_status
),

order_yearly_all as (
  select
    order_year,
    sum(y_total_orders) as y_all_orders
  from
    dm_agg_yearly
  group by
    order_year
  order by
    order_year
),

sales_yearly_join as ( 
  select
    ay.order_year,
    ay.y_total_orders,
    ay.y_total_values,
    ay.y_total_items,
    oy.y_all_orders
  from dm_agg_yearly ay
  left join order_yearly_all oy
    on ay.order_year = oy.order_year
  where
    ay.order_status = 'Complete'
),

  
sales_yearly_cum as (
  select
    order_year,
    SUM(y_total_values) OVER (ORDER BY order_year) AS total_values_cum,
    SUM(y_total_orders) OVER (ORDER BY order_year) AS total_orders_cum,
    SUM(y_total_items) OVER (ORDER BY order_year) AS total_items_cum,
    SUM(y_all_orders) OVER (ORDER BY order_year) AS all_orders_cum,
    total_values_cum / total_orders_cum AS avg_ovalues_cum,
    total_items_cum / total_orders_cum AS avg_oitems_cum,
    ((total_orders_cum * 100) / all_orders_cum) AS conversion_rate_cum
  from
    sales_yearly_join
)

select
  order_year,
  total_values_cum,
  total_orders_cum,
  avg_ovalues_cum,
  avg_oitems_cum,
  conversion_rate_cum,
  CASE
    WHEN LAG(total_values_cum) OVER (ORDER BY order_year) IS NOT NULL
    THEN ((total_values_cum - LAG(total_values_cum) OVER (ORDER BY order_year)) / LAG(total_values_cum) OVER (ORDER BY order_year))
    ELSE NULL
    END AS total_values_growth,
  CASE
    WHEN LAG(total_orders_cum) OVER (ORDER BY order_year) IS NOT NULL
    THEN ((total_orders_cum - LAG(total_orders_cum) OVER (ORDER BY order_year)) / LAG(total_orders_cum) OVER (ORDER BY order_year))
    ELSE NULL
    END AS total_orders_growth,
  CASE
    WHEN LAG(avg_ovalues_cum) OVER (ORDER BY order_year) IS NOT NULL

    THEN ((avg_ovalues_cum - LAG(avg_ovalues_cum) OVER (ORDER BY order_year)) / LAG(avg_ovalues_cum) OVER (ORDER BY order_year))
    ELSE NULL
    END AS avg_ovalues_growth,
  CASE 
    WHEN LAG(avg_oitems_cum) OVER (ORDER BY order_year) IS NOT NULL
    THEN ((avg_oitems_cum - LAG(avg_oitems_cum) OVER (ORDER BY order_year)) / LAG(avg_oitems_cum) OVER (ORDER BY order_year))
    ELSE NULL
    END AS avg_oitems_growth,
  CASE
    WHEN LAG(conversion_rate_cum) OVER (ORDER BY order_year) IS NOT NULL
    THEN ((conversion_rate_cum - LAG(conversion_rate_cum) OVER (ORDER BY order_year)) / LAG(conversion_rate_cum) OVER (ORDER BY order_year))
    ELSE NULL
    END AS conversion_rate_growth
from
  sales_yearly_cum
order BY
  order_year DESC
```

## Sales Performance Aggregate
<center>
<Grid cols = 5>
<BigValue
  data={agg_sales_yearly_cum_growth[0]}
  title="Total Sales"
  value=total_values_cum
  fmt = usd2m
  comparison=total_values_growth
  comparisonFmt=pct1
  comparisonTitle="from prev. year"
/>
<BigValue
  data={agg_sales_yearly_cum_growth[0]}
  title="Total Orders"
  value=total_orders_cum
  fmt = '#,##0.00,"k"'
  comparison=total_orders_growth
  comparisonFmt=pct1
  comparisonTitle="from prev. year"
/>
<BigValue
  data={agg_sales_yearly_cum_growth[0]}
  title="Avg Order Value"
  value=avg_ovalues_cum
  fmt = '"$"#,##0.00'
  comparison=avg_ovalues_growth
  comparisonFmt=pct1
  comparisonTitle="from prev. year"
/>
<BigValue
  data={agg_sales_yearly_cum_growth[0]}
  title="Avg Order Items"
  value=avg_oitems_cum
  fmt = '#,##0 "item"'
  comparison=avg_oitems_growth
  comparisonFmt=pct1
  comparisonTitle="from prev. year"
/>
<BigValue
  data={agg_sales_yearly_cum_growth[0]}
  title="Conversion Rate"
  value=conversion_rate_cum
  fmt = '#,##0.00"%"'
  comparison=conversion_rate_growth
  comparisonFmt=pct1
  comparisonTitle="from prev. year"
/>
</Grid>
</center>

## Sales Performance Timeline

```sql agg_sales_monthly

with dm_agg_monthly as (
		select
		date_trunc('month', order_date) as order_month,
		order_status,
		SUM(total_orders) AS m_total_orders,
		SUM(total_values) AS m_total_values,
		SUM(total_items) AS m_total_items,
		(m_total_values / m_total_orders) AS m_avg_ovalues,
		(m_total_items / m_total_orders) AS m_avg_oitems
	from
		${dm_agg_daily_filtered}
	group by
		order_month,
		order_status

),

order_monthly_all as (
	select
		order_month,
		sum(m_total_orders) as m_all_orders
	from
		dm_agg_monthly
	group by
		order_month
	order by
		order_month
)

select
	ay.order_month,
	ay.m_total_orders,
	ay.m_total_values,
	ay.m_total_items,
	oy.m_all_orders,
	ay.m_avg_ovalues,
	ay.m_avg_oitems,
	((ay.m_total_orders*100) / oy.m_all_orders) AS m_conversion_rate
from dm_agg_monthly ay
left join order_monthly_all oy
	on ay.order_month = oy.order_month
where
	ay.order_status = 'Complete'
order by
	ay.order_month
```

<Dropdown
  title="Select a metric"
  name=dropdown_monthly_metrics
  value=column_name
  defaultValue = "m_total_values"
>
  <DropdownOption valueLabel="Total Sales" value="m_total_values"/>
  <DropdownOption valueLabel="Total Orders" value="m_total_orders"/>
  <DropdownOption valueLabel="Average Order Values" value="m_avg_ovalues"/>
  <DropdownOption valueLabel="Average Order Items" value="m_avg_oitems"/>
  <DropdownOption valueLabel="Conversion Rate" value="m_conversion_rate"/>
</Dropdown>

<center>
<LineChart
  data={agg_sales_monthly}
  x=order_month
  y={inputs.dropdown_monthly_metrics.value}
  yScale=true
  yGridlines=false
  yAxisLabels=false
  yAxisTitle={inputs.dropdown_monthly_metrics.label}
  labels=false
  sort=false>
  <ReferenceArea
    xMin='2020-01-01'
    xMax='2022-12-31'
    label="Covid-19" color=red
  />
</LineChart>
</center>

## Sales Performance Ranking by Country and Product Category

<Dropdown
  title="Select a metric"
  name=dropdown_alltime_metrics
  value=column_name
  defaultValue = "a_total_values"
>
  <DropdownOption valueLabel="Total Sales" value="a_total_values"/>
  <DropdownOption valueLabel="Total Orders" value="a_total_orders"/>
  <DropdownOption valueLabel="Total Items" value="a_total_items"/>
</Dropdown>

```sql top5_country
select
  country,
  sum(total_values) AS a_total_values,
  sum(total_orders) AS a_total_orders,
  sum(total_items) AS a_total_items
from
  ${dm_country_prodcat_daily_filtered}
where
  order_status = 'Complete'
group by
  country
order by '${inputs.dropdown_alltime_metrics.value}' desc
limit 5
```

```sql top5_prodcat
select
  category,
  sum(total_values) AS a_total_values,
  sum(total_orders) AS a_total_orders,
  sum(total_items) AS a_total_items
from
  ${dm_country_prodcat_daily_filtered}
where
  order_status = 'Complete'
group by
  category
order by '${inputs.dropdown_alltime_metrics.value}' desc
limit 5
```

<center>
{#if inputs.dropdown_alltime_metrics.value == 'a_total_values'}

  <Grid cols = 2>
  <BarChart
  data={top5_country}
  x=country
  y={inputs.dropdown_alltime_metrics.value}
  swapXY=true
  yFmt=usd0k
  title="Top 5 Total Sales by Country"
  />
  <BarChart
  data={top5_prodcat}
  x=category
  y={inputs.dropdown_alltime_metrics.value}
  swapXY=true
  yFmt=usd0k
  title="Top 5 Total Sales by Product Category"
  />
  </Grid>

{:else}

  <Grid cols = 2>
  <BarChart
  data={top5_country}
  x=country
  y={inputs.dropdown_alltime_metrics.value}
  swapXY=true
  yFmt='#,##0.0,"k"'
  title="Top 5 Total Sales by Country"
  />
  <BarChart
  data={top5_prodcat}
  x=category
  y={inputs.dropdown_alltime_metrics.value}
  swapXY=true
  yFmt= '#,##0.0,"k"'
  title="Top 5 Total Sales by Product Category"
  />
</Grid>
{/if}
</center>