---
title: Country-Wise Sales Report
queries:
    - dm_country_prodcat_daily: dm_country_prodcat_daily.sql
---

<DateRange
    name=daterange_filter_c
    data={dm_country_prodcat_daily}
    dates=order_date
/>

```sql dm_country_prodcat_daily_filtered
select *
from ${dm_country_prodcat_daily}
where
    order_date between '${inputs.daterange_filter_c.start}' and '${inputs.daterange_filter_c.end}'
```

```sql country_agg_sales
select
    country,
    sum(total_values) as c_total_values,
    sum(total_orders) as c_total_orders,
    sum(total_items) as c_total_items,
    RANK() OVER (ORDER BY c_total_values DESC) AS c_rank
FROM
    ${dm_country_prodcat_daily_filtered}
where order_status = 'Complete'
Group by country
```

Select a country to analyze: <Dropdown data={country_agg_sales} name=dd_country value=country defaultValue = "Japan" order=country> </Dropdown>

```sql country_bignumber
select * from ${country_agg_sales} where country='${inputs.dd_country.value}'
```

<center>
<Grid cols=4>
    <BigValue
        data={country_bignumber}
        value=c_rank
        title="Rank"
    />
    <BigValue
        data={country_bignumber}
        value=c_total_values
        title="Total Sales"
        fmt =usd2k
    />
    <BigValue
        data={country_bignumber}
        value=c_total_orders
        title="Total Orders"
        fmt='#,##0.00,"k"'
    />
    <BigValue
        data={country_bignumber}
        value=c_total_items
        title="Total Items"
        fmt='#,##0.00,"k"'
    />    
</Grid>
</center>

## Sales Performance over Time

```sql country_sales_monthly

with dm_agg_monthly as (
	select
		date_trunc('month', order_date) as order_month,
		order_status,
		SUM(total_orders) AS m_total_orders,
		SUM(total_values) AS m_total_values,
		SUM(total_items) AS m_total_items,
	from
		${dm_country_prodcat_daily_filtered}
    where country = '${inputs.dd_country.value}'
	group by
		order_month,
		order_status,
        country

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
  name=dd_metrics
  value=column_name
  defaultValue = "m_total_values"
>
  <DropdownOption valueLabel="Total Sales" value="m_total_values"/>
  <DropdownOption valueLabel="Total Orders" value="m_total_orders"/>
  <DropdownOption valueLabel="Total Items" value="m_total_items"/>
</Dropdown>

<center>
<LineChart
  data={country_sales_monthly}
  x=order_month
  y={inputs.dd_metrics.value}
  yScale=true
  yGridlines=false
  yAxisLabels=false
  yAxisTitle="{inputs.dd_metrics.label} of {inputs.dd_country.value}"
  labels=false
  sort=false>
  <ReferenceArea
    xMin='2020-01-01'
    xMax='2022-12-31'
    label="Covid-19" color=red
  />
</LineChart>
</center>

## Most and Least Selling Product Categories

```sql country_top5prod
select
    category,
    sum(total_values) as m_total_values,
    sum(total_orders) as m_total_orders,
    sum(total_items) as m_total_items
from
	${dm_country_prodcat_daily_filtered}
where country = '${inputs.dd_country.value}' and order_status  = 'Complete'
group by
    category
order by
    ${inputs.dd_metrics.value} desc
limit 5
```

```sql country_bot5prod
select
    category,
    sum(total_values) as m_total_values,
    sum(total_orders) as m_total_orders,
    sum(total_items) as m_total_items
from
	${dm_country_prodcat_daily_filtered}
where country = '${inputs.dd_country.value}' and order_status = 'Complete'
group by
    category
order by
    ${inputs.dd_metrics.value}
limit 5
```

<center>
<Grid cols=2>
<BarChart
    data={country_top5prod}
    x=category
    y={inputs.dd_metrics.value}
    yScale=true
    swapXY=true
/>
<BarChart
    data={country_bot5prod}
    x=category
    y={inputs.dd_metrics.value}
    yScale=true
    swapXY=true
    sort=false
/>
</Grid>
</center>

