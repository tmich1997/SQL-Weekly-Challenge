-- Cleaning, Part 1: Cleaning the "customer_orders" table
DROP TABLE IF EXISTS clean_customer_orders;

CREATE TABLE clean_customer_orders (
    "order_id" INT,
    "customer_id" INT,
    "pizza_id" INT,
    "exclusions" VARCHAR(4),
    "extras" VARCHAR(4),
    "order_time" DATETIME
);

INSERT INTO clean_customer_orders 
    ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
SELECT
    co.order_id,
    co.customer_id,
    co.pizza_id,
    (CASE
        when
            co.exclusions = '' or co.exclusions = 'null'
        then
            null
        else
            co.exclusions
    end) as exclusions,
    (CASE
        when
            co.extras = 'null' or co.extras = ''
        then
            null
        else
            co.extras
    end) as extras,
    co.order_time
from PizzaRunner..customer_orders co;

SELECT *
from clean_customer_orders;

-- Cleaning, Part 2: Cleaning the "runner_orders" table
DROP TABLE IF EXISTS clean_runner_orders;

CREATE TABLE clean_runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);


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
    COUNT(ro.runner_id) as successful_orders
from PizzaRunner..runner_orders ro
where ro.distance != 'null'
GROUP BY ro.runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT
    pn.pizza_name,
    COUNT(co.pizza_id)
from PizzaRunner..customer_orders co
join PizzaRunner..pizza_names pn
    on pn.pizza_id = co.pizza_id
join PizzaRunner..runner_orders ro
    on ro.order_id = co.order_id
group BY pn.pizza_name;
