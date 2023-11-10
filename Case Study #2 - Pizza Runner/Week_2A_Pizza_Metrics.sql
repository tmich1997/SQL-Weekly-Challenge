-- 1. How many pizzas were ordered?
SELECT
    count(order_id) as order_count
from PizzaRunner..customer_orders
;

-- 2. How many unique customer orders were made?
SELECT
    COUNT(distinct order_id) as distinct_order
from PizzaRunner..customer_orders
;

-- 3. How many successful orders were delivered by each runner?
SELECT
    ro.runner_id,
    COUNT(ro.runner_id) as successful_orders
from PizzaRunner..runner_orders ro
where 
    ro.distance != 'null'
GROUP BY 
    ro.runner_id
;

-- 4. How many of each type of pizza was delivered?
SELECT
    pn.pizza_name as Pizza_type,
    COUNT(*) as #_of_pizzas_deliveries
FROM clean_runner_orders rc
JOIN clean_customer_orders co
    ON rc.order_id = co.order_id
JOIN pizza_names pn
    on co.pizza_id = pn.pizza_id
WHERE 
    cancellation IS NULL
GROUP BY 
    pn.pizza_name
;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
    cco.customer_id,
    pn.pizza_name,
    COUNT(cco.pizza_id) as number_of_pizzas_ordered
from clean_customer_orders cco
JOIN pizza_names pn
    ON cco.pizza_id = pn.pizza_id
GROUP BY
    cco.customer_id,
    pn.pizza_name
order BY 
    cco.customer_id
;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT
    top 1
    cco.customer_id,
    cco.order_id,
    COUNT(cco.order_id) pizza_count
from clean_customer_orders cco
GROUP BY
    cco.customer_id,
    cco.order_id
ORDER BY
    COUNT(cco.order_id) desc
;

-- 7. For each customer, how many delivered pizzas had at least 1 
-- change and how many had no changes?
-- 1 change: either EXCLUSIONS or EXTRAS is NOT NULL
-- no change: both EXTRAS and EXCLUSIONS is NULL
SELECT
    cco.customer_id,
    sum(
        CASE
            WHEN cco.extras is null and cco.exclusions is null then 1
            else 0
        END
    ) as no_change_in_pizza,
    sum(
        CASE
            WHEN cco.extras is not null or cco.exclusions is not null then 1
            else 0
        END
    ) as change_in_pizza
from clean_customer_orders cco
JOIN clean_runner_orders cro
    on cro.order_id = cco.order_id
WHERE
    cro.cancellation is null
GROUP BY
    cco.customer_id
ORDER BY
    cco.customer_id
;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT
    cco.customer_id,
    SUM(
        CASE
            WHEN cco.extras is not null and cco.exclusions is not null then 1
            else 0
        END
    ) as no_change_in_pizza
from clean_customer_orders cco
JOIN clean_runner_orders cro
    on cro.order_id = cco.order_id
WHERE
    cro.cancellation is null
GROUP BY
    cco.customer_id
ORDER BY
    cco.customer_id
;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT
    count(cco.order_id) as pizza_count,
    datepart(hour, cco.order_time) as hour_of_day
from clean_customer_orders cco
GROUP BY
    datepart(hour, cco.order_time)
;

-- 10. What was the volume of orders for each day of the week?
SELECT
    count(cco.order_id) as pizza_count,
    DATENAME(DW, cco.order_time) as day_of_week
from clean_customer_orders cco
GROUP BY
    DATENAME(DW, cco.order_time)
;