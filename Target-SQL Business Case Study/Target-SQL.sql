-- =====================================================================================================================================
--I.	Import the dataset and do usual exploratory analysis steps like checking the structure & characteristics of the dataset:
-- =====================================================================================================================================


-- ==============================================================================
--Q I-A.Data type of all columns in the “customers” table.

DESCRIBE Target.customers;
OR
DESC  Target.customers;

-- ==============================================================================

-- ==============================================================================
--Q I-B. Get the time range between which the orders were placed.

select 
    min(extract(TIME from order_purchase_timestamp)) as first_order_time,
    max(extract(Time from order_purchase_timestamp)) as last_order_time
from `Target.orders`

-- ==============================================================================

-- =========================================================================================
-- Q I-C.	Count the Cities & States of customers who ordered during the given period.

SELECT  COUNT(DISTINCT(c.customer_state)) as num_of_states,
        COUNT(DISTINCT(c.customer_city)) as num_of_cities, 
        
FROM `Target.orders`o join `Target.customers` c
ON o.customer_id=c.customer_id
WHERE o.order_purchase_timestamp BETWEEN 
TIMESTAMP("2016-05-20") AND TIMESTAMP("2016-12-30")

-- =========================================================================================

-- =========================================================================================
--II.	In-depth Exploration:
-- =========================================================================================

-- =========================================================================================
-- Q II-A.	Is there a growing trend in the no. of orders placed over the past years? 

SELECT EXTRACT(YEAR from order_purchase_timestamp) as order_year,
count(order_id) as total_orders_placed
FROM `Target.orders`
group by order_year
order by order_year

-- =========================================================================================

-- ====================================================================================================
-- Q II-B.	Can we see some kind of monthly seasonality in terms of the no. of orders being placed?

SELECT EXTRACT(YEAR from order_purchase_timestamp) as order_year,
EXTRACT(MONTH from order_purchase_timestamp) as order_month,
count(order_id) as total_orders_placed
FROM `Target.orders`
group by order_year,order_month
order by order_year,order_month
LIMIT 10

-- ====================================================================================================

-- ====================================================================================================
--Q II-C.	During what time of the day, do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night)  
-- 0-6 hrs : Dawn
-- 7-12 hrs : Mornings
-- 13-18 hrs : Afternoon
-- 19-23 hrs : Night

SELECT 
      CASE
WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 0 AND 6 THEN "Dawn"
WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 7 AND 12 THEN "Mornings"
WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 13 AND 18 THEN "Afternoon"
WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 19 AND 23 THEN "Night"
      END as time_of_day,
      count(*) as total_orders
FROM `Target.orders`
group by time_of_day
order by total_orders 

-- ====================================================================================================

-- ====================================================================================================
-- III.	Evolution of E-commerce orders in the Brazil region: 
-- ====================================================================================================

-- ====================================================================================================
-- Q III-A.	Get the month on month no. of orders placed in each state.

SELECT 
    c.customer_state AS state,
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS order_year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS order_month,
    COUNT(o.order_id) AS total_orders
FROM `Target.orders` o JOIN `Target.customers` c 
ON   o.customer_id = c.customer_id
GROUP BY 
    c.customer_state,
    EXTRACT(YEAR FROM o.order_purchase_timestamp),
    EXTRACT(MONTH FROM o.order_purchase_timestamp)
ORDER BY 
    state,
    order_year,
    order_month;

-- ====================================================================================================

-- ====================================================================================================
-- Q III-B.	How are the customers distributed across all the states?

SELECT customer_state,
       count(*) as total_customer
FROM `Target.customers`
group by customer_state
order by total_customer 
LIMIT 10;

-- ====================================================================================================

-- ====================================================================================================
--IV.	Impact on Economy: Analyze the money movement by e-commerce by looking at order prices, freight and others.
-- ====================================================================================================


-- ====================================================================================================
-- Q IV-A. Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only). 

with final as (
Select format_date('%Y', order_purchase_timestamp) as yr_dt,
      sum(p.payment_value) as cost
from `target.orders` o
inner join `target.payments` p
on p.order_id = o.order_id
where format_date('%Y', order_purchase_timestamp) in ('2017','2018')
and extract(month from order_purchase_timestamp) between 1 and 8
group by 1)

Select yr_dt, cost,
      lead(cost,1) over(order by yr_dt ) as nxt_yr_cost,
      100* (lead(cost,1) over(order by yr_dt )- cost)/cost as prec_cost_yoy
from final
order by 1
-- ====================================================================================================
-- Q IV-B.	Calculate the Total & Average value of order price for each state.
SELECT  c.customer_state, 
        count(o.order_id) as total_orders,
        round(avg(p.payment_value),2) as avg_order_price
FROM `Target.customers` c LEFT JOIN `Target.orders` o 
ON  c.customer_id=o.customer_id
LEFT JOIN `Target.payments` p ON o.order_id=p.order_id
group by c.customer_state
order by c.customer_state
LIMIT 10;
-- ====================================================================================================
-- Q IV-C.	Calculate the Total & Average value of order freight for each state.
SELECT
    c.customer_state AS state,
    round(SUM(ot.freight_value),2) AS total_freight_value,
    round(AVG(ot.freight_value),2) AS avg_freight_value
FROM `Target.customers` c LEFT JOIN `Target.orders` o 
ON c.customer_id=o.customer_id LEFT JOIN `Target.order_items` ot 
ON o.order_id=ot.order_id
GROUP BY c.customer_state
ORDER BY c.customer_state
LIMIT 10;

-- ====================================================================================================
-- V.	Analysis based on sales, freight and delivery time.
-- ====================================================================================================

-- ====================================================================================================
-- Q V-A. Find the no. of days taken to deliver each order from the order’s purchase date as delivery time.
-- Also, calculate the difference (in days) between the estimated & actual delivery date of an order.
-- Do this in a single query.
-- You can calculate the delivery time and the difference between the estimated & actual delivery date using the given formula:
-- time_to_deliver = order_delivered_customer_date - order_purchase_timestamp.
-- diff_estimated_delivery = order_estimated_delivery_date - order_delivered_customer_date

SELECT
    order_id,
    DATE_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY) AS time_to_deliver,
    DATE_DIFF(order_estimated_delivery_date, order_delivered_customer_date, DAY) AS diff_estimated_delivery
FROM `Target.orders` 
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL
LIMIT 10;

-- ====================================================================================================
-- Q V-B.	Find out the top 5 states with the highest & lowest average freight value.
(Select c.customer_state,
      avg(freight_value) as avg_freight_value,
      'top states by friegt' as value
from `target.orders` o
inner join `target.order_items` oi
on o.order_id =oi.order_id
inner join `target.customers` c
on o.customer_id = c.customer_id
group by 1
order by 2 desc
limit 5)

union all

(Select c.customer_state,
      avg(freight_value) as avg_freight_value,
      'bottom states by friegt' as value
from `target.orders` o
inner join `target.order_items` oi
on o.order_id =oi.order_id
inner join `target.customers` c
on o.customer_id = c.customer_id
group by 1
order by 2
limit 5)


-- ====================================================================================================
--Q V.C.	Find out the top 5 states with the highest & lowest average delivery time.
SELECT
    CASE 
        WHEN row_num_desc <= 5 THEN 'Highest'
        WHEN row_num_asc <= 5 THEN 'Lowest'
    END AS type,
    state,
    avg_delivery_days
FROM (
    	SELECT
       c.customer_state AS state,
round(AVG(DATE_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)),2) AS avg_delivery_days,
ROW_NUMBER() OVER (ORDER BY AVG(DATE_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)) DESC) AS row_num_desc,
ROW_NUMBER() OVER (ORDER BY AVG(DATE_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)) ASC) AS row_num_asc
    	FROM `Target.orders` o
    	JOIN `Target.customers` c
        ON o.customer_id = c.customer_id
    	WHERE o.order_delivered_customer_date IS NOT NULL
    	GROUP BY c.customer_state
) AS ranked_states
WHERE row_num_desc <= 5 OR row_num_asc <= 5
ORDER BY type DESC, avg_delivery_days ASC;

-- ====================================================================================================
-- Q V-D.	Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery.

You can use the difference between the averages of actual & estimated delivery date to figure out how fast the delivery was for each state. 
SELECT 
    	c.customer_state as state,
ROUND(AVG(DATE_DIFF(o.order_delivered_customer_date,o.order_estimated_delivery_date, DAY)), 2) AS avg_diff_days
FROM `Target.orders` o JOIN `Target.customers` c 
ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY state
ORDER BY avg_diff_days ASC  
LIMIT 5;

-- ====================================================================================================
-- VI.	Analysis based on the payments:
-- ====================================================================================================

-- ====================================================================================================
-- Q VI-A.	Find the month on month no. of orders placed using different payment types.

SELECT
    FORMAT_TIMESTAMP('%Y-%m', o.order_purchase_timestamp) AS year_month,
    p.payment_type,
    COUNT(DISTINCT o.order_id) AS total_orders,
FROM `Target.orders` o JOIN `Target.payments` p
    ON o.order_id = p.order_id
GROUP BY year_month, p.payment_type
ORDER BY year_month, p.payment_type;

-- ====================================================================================================
-- Q VI-B.	Find the no. of orders placed on the basis of the payment installments that have been paid.

SELECT
    payment_installments,
    COUNT(DISTINCT order_id) AS total_orders
FROM `Target.payments`
GROUP BY payment_installments
ORDER BY total_orders desc;
-- ====================================================================================================









