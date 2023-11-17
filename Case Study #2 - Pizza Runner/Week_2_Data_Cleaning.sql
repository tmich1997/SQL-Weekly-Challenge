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

INSERT INTO clean_runner_orders
     ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
SELECT
    ro.order_id,
    ro.runner_id,
    (CASE
        when 
            ro.pickup_time = 'null'
        then 
            null
        else
            ro.pickup_time
    END) as pickup_time,
    (CASE
        when 
            ro.distance like '%km'
        then 
            TRY_CAST(SUBSTRING(ro.distance, 1, LEN(ro.distance) - 2) as float)
        else
            TRY_CAST(distance as float)
    end) as distance_km,
    (CASE
        when
            ro.duration like '%minutes'
        then
            REPLACE(duration, 'minutes', '')
        when
            ro.duration like '%mins'
        then
            REPLACE(duration, 'mins', '')
        when
            ro.duration like '%minute'
        then
            REPLACE(duration, 'minute', '')
        when 
            ro.duration = 'null'
        then 
            null
        else
            ro.duration
    END) as duration_min,
    (CASE
        when
            ro.cancellation = '' or ro.cancellation = 'null'
        then
            null
        else
            ro.cancellation
    END) as cancellation
FROM runner_orders ro;

-- Altering the table to change the data-type
ALTER TABLE pizza_names
ALTER COLUMN pizza_name VARCHAR(50);

ALTER TABLE clean_runner_orders
ALTER COLUMN distance DECIMAL(13,4);