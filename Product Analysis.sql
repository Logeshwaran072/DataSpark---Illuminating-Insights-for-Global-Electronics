use dataspark;

    
#product popularity
    select 
		p.category,p.subcategory,p.product_name,p.brand,
        sum(s.quantity) as total_products_sold,
        sum(s.quantity * p.unit_price_usd) as total_price
        from product as p join sales as s 
        on p.productkey = s.productkey
        group by p.category,p.subcategory,p.product_name,p.brand
        order by total_price desc;

        
	# profit margin 
    select 
		p.product_name,p.brand,p.category,p.subcategory,
		sum(s.quantity * p.unit_cost_usd) as making_price,
        sum(s.quantity * p.unit_price_usd) as Product_price,
        sum(s.quantity * p.unit_price_usd) - sum(s.quantity * p.unit_cost_usd) as profit,
        ((sum(s.quantity * p.unit_price_usd) - sum(s.quantity * p.unit_cost_usd)) / sum(s.quantity * p.unit_price_usd)) *100 as profit_margin
        from product as p join sales as s
        on p.productkey = s.productkey
        group by p.product_name,p.brand,p.category,p.subcategory
        order by profit_margin desc;
        
#category analysis
select 
	p.category,p.subcategory,
    sum(s.quantity) as total_products_sold,
	sum(s.quantity * p.unit_price_usd) as total_price,
    avg(p.unit_price_usd) as avg_unit_price
    from product as p join sales as s
    on p.productkey = s.productkey
    group by p.category,p.subcategory
    order by  total_price desc;
        

