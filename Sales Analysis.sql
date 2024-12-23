use dataspark;


# total Sales by product
select
	p.product_name,p.category,
    sum(s.quantity) as total_quantity_sold,
    round(sum(s.quantity * p.unit_price_usd),2) as sales_amount 
    from sales as s inner join product as p on s.productKey = p.productKey 
	group by p.product_name,p.category
    order by sales_amount desc;

# total Sales by stores

select
	st.country,st.storekey,c.state,c.city,
    round(sum(s.quantity * p.unit_price_usd),2) as store_total_sales,
    sum(s.quantity) as Total_quantity from sales as s 
    join stores as st on s.storekey = st.storekey
    join product as p on s.productKey = p.productKey
    join customer as c on s.customerkey = c.customerkey
    group by st.country,st.storekey,c.state,c.city
    order by st.country,st.storekey;
    
 # Sales by currency
 select
	s.currency_code,
    round(sum(s.quantity * p.unit_price_usd),2) as base_sales_value,
    round(sum(s.quantity * p.unit_price_usd * e.exchange),2) as total_sales_in_usd,
    round(sum(s.quantity * p.unit_price_usd * e.exchange) - sum(s.quantity*p.unit_price_usd),2) as exchange_rate_impact,
    sum(s.quantity) as total_quantity from sales as s
    inner join product as p on s.productKey = p.productKey
    inner join exchange as e on s.currency_code = e.currency
    and s.order_date = e.date
    group by s.currency_code
    order by total_sales_in_usd;
    
# Sales by currency 
 select
	s.currency_code,
    concat(date_format(e.date, "%Y"), "-Q",
	case 
        when month(e.date) between 1 and 3 then 1
        when month(e.date) between 4 and 6 then 2
        when month(e.date) between 7 and 9 then 3
        when month(e.date) between 10 and 12 then 4
	end) as quarter,
    max(e.exchange) as maximun_exchange,
    min(e.exchange) as minimum_exchange,
    max(e.exchange) - min(e.exchange) as exchange_rate_variation,
    sum(s.quantity * p.unit_price_usd) as base_sales_value,
    sum(s.quantity * p.unit_price_usd * e.exchange) as total_sales_in_usd,
    sum(s.quantity * p.unit_price_usd * e.exchange) - sum(s.quantity*p.unit_price_usd) as exchange_rate_impact,
    sum(s.quantity) as total_quantity from sales as s
    inner join product as p on s.productKey = p.productKey
    inner join exchange as e on s.currency_code = e.currency
    and s.order_date = e.date
    group by s.currency_code,quarter
    order by s.currency_code,quarter;
 
# overall sales performance

select 
	date_format(s.order_date, "%Y") as order_year,
    sum(s.quantity * p.unit_price_usd) as total_sales_value,
    sum(s.quantity) as total_quantity
    from sales as s
    inner join product as p on p.productkey = s.productkey
    group by date_format(s.order_date, "%Y")
    order by total_sales_value desc;