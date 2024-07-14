select * from coffee_shop_sales;

SELECT concat((round(sum(unit_price  * transaction_qty)))/1000,  "K") AS Total_Sales from coffee_shop_sales
where month(transaction_date) = 3; -- March Month;

select month(transaction_date) as month,
round(sum(unit_price  * transaction_qty)) as Total_Sales, -- gives total sales
(sum(unit_price  * transaction_qty) - lag(sum(unit_price  * transaction_qty),1) -- month sales difference lag is a window function
over (order by month(transaction_date))) / lag(sum(unit_price  * transaction_qty),1) -- dividing everything by previos month sales
over (order by month(transaction_date)) * 100 as mom_increase_percentage
from coffee_shop_sales
where month(transaction_date) in (4,5)
group by month(transaction_date)
order by month(transaction_date)  ;



-- total order analysis by respective month
select count(transaction_id) as total_orders
from coffee_shop_sales
where 
month(transaction_date)=3;

select month(transaction_date) as month,
round(count(transaction_id)) as Total_orders, -- gives total sales
(count(transaction_id) - lag(count(transaction_id),1) -- month sales difference lag is a window function
over (order by month(transaction_date))) / lag(count(transaction_id),1) -- dividing everything by previos month sales
over (order by month(transaction_date)) * 100 as mom_increase_percentage
from coffee_shop_sales
where month(transaction_date) in (4,5)
group by month(transaction_date)
order by month(transaction_date)  ;

-- quantity analysis
select sum(transaction_qty) as total_quantity_sold
from coffee_shop_sales
where 
month(transaction_date)=5;

select month(transaction_date) as month,
round(sum(transaction_qty)) as Total_quantity_sold, -- gives total sales
(sum(transaction_qty) - lag(sum(transaction_qty),1) -- month sales difference lag is a window function
over (order by month(transaction_date))) / lag(sum(transaction_qty),1) -- dividing everything by previos month sales
over (order by month(transaction_date)) * 100 as mom_increase_percentage
from coffee_shop_sales
where month(transaction_date) in (4,5)
group by month(transaction_date)
order by month(transaction_date)  ;




-- calender heat map query

select 
	concat(round(sum(unit_price  * transaction_qty)/1000,1 ), 'K')as Total_Sales,
	concat(round(sum(transaction_qty)/1000,1 ), 'K')as Total_quantity_sold,
    concat(round(count(transaction_id)/1000,1), 'K') as total_orders
    
    from coffee_shop_sales
    where
		transaction_date = '2023-05-18';


-- sales analysis by weekdays and weekends
select 
	case when  dayofweek(transaction_date) in (1,7) then  'weekends'
	else 'weekdays'
    end as day_type,
    concat(round(sum(unit_price  * transaction_qty)/1000,1 ), 'K')as Total_Sales
    from coffee_shop_sales
    where month(transaction_date) = 2
    group by
		case when dayofweek(transaction_date) in (1,7) then  'weekends'
        else 'weekdays'
        end 
        
-- sales analysis by store location
select 
	store_location,
	concat(round(sum(unit_price  * transaction_qty)/1000,2), 'K')  as total_sales
    from coffee_shop_sales
    where month(transaction_date) = 5
    group by store_location
    order by total_sales desc
select concat(round(AVG(total_sales)/1000,1), 'K')  as Avg_sales
from
	(
    select sum(unit_price  * transaction_qty) as  total_sales
    from coffee_shop_sales
    where month(transaction_date) = 5
    group by transaction_date
     ) as internal_query;
     
-- daily sales for that month
SELECT 
    DAY(transaction_date) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    DAY(transaction_date)
ORDER BY 
    DAY(transaction_date);
    
-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER  () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
    
    
    -- sales by product category
SELECT 
	product_category,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC
limit 10

-- SALES BY DAY | HOUR
SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    coffee_shop_sales
WHERE 
    DAYOFWEEK(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND HOUR(transaction_time) = 8 -- Filter for hour number 8
    AND MONTH(transaction_date) = 5; -- Filter for May (month number 5)

-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;
    
    -- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);




