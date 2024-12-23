use dataspark;

#Store Performance Analysis

 select 
	st.storekey,st.country,st.square_meters,st.open_date,
    sum(s.quantity * p.unit_price_usd) as total_sales,
    sum(s.quantity) as total_quantity_sold,
    sum(s.quantity * p.unit_price_usd) / st.square_meters as revenue_per_sq_meter,
    datediff(current_date() ,st.open_date)/365 as years_open,
    case 
		when datediff(current_date(),st.open_date)/365 between 1 and 2 then "1-2 years"
        when datediff(current_date(),st.open_date)/365 between 3 and 5 then "3-5 years"
		when datediff(current_date(),st.open_date)/365 between 6 and 10 then "6-10 years"
		when datediff(current_date(),st.open_date)/365 > 10 then "10+ years"
        else "less than 1 year"
    end as Store_Age_group
    from stores as st join sales as s 
    on st.storekey = s.storekey
    join product as p on p.productkey = s.productkey
    group by st.storekey,st.country,st.square_meters,st.open_date
    order by total_sales desc;
    
    
 #Geographical Analysis
 
 select
	st.country,st.state,st.storekey,
    case 
		when st.square_meters between 0 and 500 then "0-500 sqm"
        when st.square_meters between 501 and 1000 then "501-1000 sqm"
        when st.square_meters between 1001 and 1500 then "1001-1500 sqm"
        when st.square_meters between 1501 and 2000 then "1501-2000 sqm"
        when st.square_meters between 2001 and 2500 then "2001-2500 sqm"
	end as Store_size,
    sum(s.quantity * p.unit_price_usd) as total_sales,
    Avg(s.quantity * p.unit_price_usd) as avg_sales_per_store,
    (count(distinct st.storekey)) as total_stores
    from stores as st
    join sales as s on st.storekey = s.storekey
    join product as p on p.productkey = s.productkey 
    group by st.country,st.state,st.storekey,st.square_meters
    order by total_sales desc;