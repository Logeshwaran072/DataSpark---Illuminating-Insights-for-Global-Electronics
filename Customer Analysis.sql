use dataspark;



#demographic distribution

select 
	c.gender,c.age_group,c.customerkey,
	c.continent,c.country,c.state,c.city,
    count(distinct c.customerkey) as customer_count,
    AVG(s.quantity * p.unit_price_usd) AS average_order_value
from ( select gender,
    case
		when floor(datediff(current_date,birthday)/365) < 12 then "under 12"
        when floor(datediff(current_date,birthday)/365) between 13 and 18  then "13-18"
        when floor(datediff(current_date,birthday)/365) between 19 and 25  then "19-25"
        when floor(datediff(current_date,birthday)/365) between 26 and 35  then "26-35"
        when floor(datediff(current_date,birthday)/365) between 36 and 45  then "36-45"
        when floor(datediff(current_date,birthday)/365) between 46 and 55  then "46-55"
        when floor(datediff(current_date,birthday)/365) between 56 and 65  then "56-65"
        else "above 65"
        end as age_group,
    continent,country,state,city,customerkey
    from customer) c
    join sales AS s ON c.customerkey = s.customerkey
	join product AS p ON s.productkey = p.productkey
    group by c.gender,c.age_group,
	c.continent,c.country,c.state,c.city,c.customerkey
    order by c.age_group;
    
    
#purchase Pattern
    
WITH customerpurchase AS (
    SELECT 
        c.customerkey,
        c.name,
        COUNT(s.order_number) AS purchase_frequency,
        AVG(s.quantity * p.unit_price_usd) AS average_order_value,
        MAX(s.quantity * p.unit_price_usd) AS max_order_value
    FROM 
        customer AS c
    JOIN 
        sales AS s ON c.customerkey = s.customerkey
    JOIN 
        product AS p ON p.productkey = s.productkey
    GROUP BY 
        c.customerkey, c.name
),
preferredproduct AS (
    SELECT 
        c.customerkey,
        p.productkey,
        p.product_name,
        SUM(s.quantity) AS total_quantity,
        RANK() OVER (PARTITION BY c.customerkey ORDER BY SUM(s.quantity) DESC) AS rank_product
    FROM 
        customer AS c
    JOIN 
        sales AS s ON c.customerkey = s.customerkey
    JOIN 
        product AS p ON p.productkey = s.productkey
    GROUP BY 
        c.customerkey, p.productkey, p.product_name
)
SELECT 
    cp.customerkey,
    cp.name,
    cp.purchase_frequency,
    cp.average_order_value,
    cp.max_order_value,
    pp.product_name AS preferred_product,
    pp.total_quantity AS preferred_product_quantity
FROM 
    customerpurchase AS cp
LEFT JOIN 
    preferredproduct AS pp 
    ON cp.customerkey = pp.customerkey AND pp.rank_product = 1
ORDER BY 
    cp.purchase_frequency DESC;
    
    
    
    


# segmentation

select
	case
		when count(s.order_number) >= 10 then "Frequent Buyers"
		when count(s.order_number) between 5 and 9 then "Occasional Buyers"
		else "Rare Buyers"
    end as segment,
    c.name,c.gender,c.customerkey,
    floor(datediff(current_date,birthday) / 365) as age,
    c.country,c.state,c.city,
    count(s.order_number) as purchase_frequency,
    AVG(s.quantity * p.unit_price_usd) AS average_order_value
from customer as c 
	join sales as s on  c.customerkey = s.customerkey
    join product as p on s.productkey = p.productkey
group by c.name,c.gender,c.customerkey,
    floor(datediff(current_date,birthday) / 365),c.country,c.state,c.city
order by  purchase_frequency desc;