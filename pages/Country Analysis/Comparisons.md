---
title: Country Sales Report Comparisons
queries:
    - dm_country_prodcat_daily: dm_country_prodcat_daily.sql
---

<DateRange
    name=daterange_filter_d
    data={dm_country_prodcat_daily}
    dates=order_date
/>

```sql dm_country_prodcat_daily_filtered
select *
from ${dm_country_prodcat_daily}
where
    order_date between '${inputs.daterange_filter_d.start}' and '${inputs.daterange_filter_d.end}'
```

```sql country_agg_sales
select
    country,
    sum(total_values) as c_total_values,
    sum(total_orders) as c_total_orders,
    sum(total_items) as c_total_items
FROM
    ${dm_country_prodcat_daily_filtered}
where order_status = 'Complete'
Group by country
```

Select countries to compare

between
<Dropdown data={country_agg_sales} name=home value=country order=country defaultValue="Japan">
</Dropdown>
and
<Dropdown data={country_agg_sales} name=away value=country order=country defaultValue="Australia">
</Dropdown>

```sql home_sales
select c_total_values from ${country_agg_sales} where country='${inputs.home.value}'
```

```sql away_sales
select c_total_values from ${country_agg_sales} where country='${inputs.away.value}'
```

<center>
<Grid cols=2>
    <BigValue
        data={home_sales}
        value=c_total_values
        title="{inputs.home.value} Total Sales"
        fmt =usd2k
    />
    <BigValue
        data={away_sales}
        value=c_total_values
        title="{inputs.away.value} Total Sales"
        fmt =usd2k
    />    
</Grid>
</center>

```sql country_agg_sales_compare
select
    country,
    order_status,
    sum(total_values) as c_total_values,
    sum(total_orders) as c_total_orders,
    sum(total_items) as c_total_items
FROM
    ${dm_country_prodcat_daily_filtered}
where country in ('${inputs.home.value}','${inputs.away.value}')
Group by country, order_status
```

```sql m_country_agg_sales_compare
select
    date_trunc('month',order_date) as order_month,
    country,
    sum(total_values) as c_total_values,
    sum(total_orders) as c_total_orders,
    sum(total_items) as c_total_items
FROM
    ${dm_country_prodcat_daily_filtered}
where
    country in ('${inputs.home.value}','${inputs.away.value}')
    and order_status='Complete'
Group by order_month,country
```

<Dropdown
  title="Select a metric"
  name=drd_metrics
  value=column_name
  defaultValue = "c_total_values"
>
  <DropdownOption valueLabel="Total Sales" value="c_total_values"/>
  <DropdownOption valueLabel="Total Orders" value="c_total_orders"/>
  <DropdownOption valueLabel="Total Items" value="c_total_items"/>
</Dropdown>

<center>
<BarChart
    data={country_agg_sales_compare}
    x=country
    y={inputs.drd_metrics.value}
    series=order_status
    swapXY=true
    yFmt= '#,##0.0,"k"'
/>
</center>

<center>
<LineChart 
    data={m_country_agg_sales_compare}
    x=order_month
    y={inputs.drd_metrics.value} 
    yAxisTitle="Sales per Month"
    series=country
    yFmt= '#,##0.0,"k"'
/>
</center>


