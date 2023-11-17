-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select
    DATEPART(WEEK, registration_date) as reg_week,
    count(runner_id) as runer_count
from runners
GROUP BY
    DATEPART(WEEK, registration_date)
;

-- 2. What was the average time in minutes it took for each runner to 
-- arrive at the Pizza Runner HQ to pickup the order?
WITH cte as(
    select
        cro.runner_id,
        DATEDIFF(MINUTE, cco.order_time, cro.pickup_time) as time_min
    FROM clean_runner_orders cro
    JOIN clean_customer_orders cco
        on cco.order_id = cro.order_id
    WHERE
        pickup_time is not NULL
)
SELECT
    runner_id,
    AVG(time_min) as average_pickup_time
FROM cte
GROUP BY
    runner_id
;

-- 3. Is there any relationship between the number of pizzas 
-- and how long the order takes to prepare?
WITH cte_pizza as (
    SELECT
        COUNT(cco.order_id) as pizza_count,
        DATEDIFF(MINUTE, cco.order_time, cro.pickup_time) as minute_to_make
    FROM clean_runner_orders cro
    JOIN clean_customer_orders cco
        on cco.order_id = cro.order_id
    WHERE
        cro.pickup_time is not null
    GROUP BY   
        cco.order_id,
        DATEDIFF(MINUTE, cco.order_time, cro.pickup_time)
)
SELECT
    pizza_count as alpha,
    avg(minute_to_make) as minutes_to_make
from cte_pizza
GROUP BY
    pizza_count
;

-- 4. What was the average distance travelled for each customer?
SELECT
    runner_id,
    round(AVG(distance),2) as avg_distance
from clean_runner_orders
GROUP BY
    runner_id
;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
with cte_distance as (
    SELECT
        DATEDIFF(MINUTE, cco.order_time, cro.pickup_time) as total_time
    FROM clean_customer_orders cco
    JOIN clean_runner_orders cro
        on cco.order_id = cro.order_id
)
SELECT
    MAX(total_time) - MIN(total_time) as diference_between
FROM cte_distance
;

-- 6. What was the average speed for each runner for each delivery 
-- and do you notice any trend for these values?
SELECT
    cco.order_id,
    cro.runner_id,
    concat(round(cast(avg(60*(distance/duration)) as float),2),  ' km/h') as speed
FROM clean_customer_orders cco
JOIN clean_runner_orders cro
    on cco.order_id = cro.order_id
WHERE
    cro.cancellation is null AND
    cro.distance is not NULL
GROUP BY
    cco.order_id,
    cro.runner_id
ORDER BY
    cco.order_id
;

-- 7. What is the successful delivery percentage for each runner?
SELECT
    runner_id,
    COUNT(pickup_time) as successful_deliveries,
    COUNT(order_id) as total_order,
    CAST(COUNT(pickup_time) as float) / COUNT(order_id) *100 as delivery
from clean_runner_orders
GROUP BY
    runner_id
;




    