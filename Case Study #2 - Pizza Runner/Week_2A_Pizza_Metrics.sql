-- 1. How many pizzas were ordered?
SELECT
    count(order_id) as order_count
from PizzaRunner..customer_orders;

-- 2. How many unique customer orders were made?
SELECT
    COUNT(distinct order_id) as distinct_order
from PizzaRunner..customer_orders;

-- 3. How many successful orders were delivered by each runner?
SELECT
    ro.runner_id,
    COUNT(ro.runner_id)
from PizzaRunner..runner_orders ro
where ro.distance != 'null'
GROUP BY ro.runner_id;