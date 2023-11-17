# 🍕 Case Study #2: Pizza Runner - Part B. Runner and Customer Experience

I am now on Part B of my seond week of the 8-week SQL challenge.

You can find the link for the seocnd challenge, [here](https://8weeksqlchallenge.com/case-study-2/).

You can find the link for, Part A. PIzza Metrics, [here](https://github.com/tmich1997/SQL-Weekly-Challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/A.%20Pizza%20Metrics.md).

You can find the solution to the first week, [here](https://github.com/tmich1997/SQL-Weekly-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/README.md?plain=1).

## Data Cleaning
### Changing data type for `clean_runner_orders`
````sql
ALTER TABLE clean_runner_orders
ALTER COLUMN distance DECIMAL(13,4);
````
#### Steps:
- Using an **ALTER** statement to change the data type of distance.
- Doing it on a table level rather than using **CAST** on a query level.

## Question and Solution

**1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)?**
````sql
select
    DATEPART(WEEK, registration_date) as reg_week,
    count(runner_id) as runer_count
from runners
GROUP BY
    DATEPART(WEEK, registration_date)
;
````
#### Steps:
- Using a **DATEPART** to find the number of the week from 2021-01-01.
- Using a **GROUP BY** to aggregate to the week level.

#### Answer:
| reg_week | runner_count |
| ----------- | ----------- |
| 1           | 1           |
| 2           | 2           |
| 3           | 1           |

**2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**
````sql
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
````
#### Steps:
- Using a CTE to save the results of the query for later use.
- Using another **SELECT** statement to query the CTE defined earlier

#### Answer:
| runner_id | average_pickup_time |
| ----------- | ----------- |
| 1           | 15           |
| 2           | 24           |
| 3           | 10           |

**3. Is there any relationship between the number of pizzas and how long the order takes to prepare?**
````sql
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
    pizza_count as pizza_count,
    avg(minute_to_make) as minutes_to_make
from cte_pizza
GROUP BY
    pizza_count
;
````
#### Steps:
- Using CTE which will be queried in the outter query.

#### Answer:
| pizza_count | minutes_to_make |
| ----------- | ----------- |
| 1           | 12           |
| 2           | 18           |
| 3           | 30           |

**4. What was the average distance travelled for each customer?**
````sql
SELECT
    runner_id,
    round(AVG(distance),2) as avg_distance
from clean_runner_orders
GROUP BY
    runner_id
;
````
#### Steps:
- Simple **SELECT** statement to display what I want.

#### Answer:
| runner_id | avg_distance |
| ----------- | ----------- |
| 1           | 15.85           |
| 2           | 23.93           |
| 3           | 10           |

**5. What was the difference between the longest and shortest delivery times for all orders?**
````sql
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
````
#### Steps:
- Using CTE to compure the time difference.
- The **DATEDIFF** is the function used find the difference in minutes.
- Using **JOIN** to join the tables.

#### Answer:
| difference_between | 
| ----------- | 
| 20         | 

**6. What was the average speed for each runner for each delivery and do you notice any trend for these values?**
````sql
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
````
#### Steps:
- Using **CONCAT** to combine the numeric values with a text value
- **CAST** was used to ensure that the numbers were computed correctly.

#### Answer:
| order_id | runner_id | speed |
| ----------- | ---------- |------------  |
| 1           | 1        |  37.5 km/h   |
| 2           | 1        |  44.4 km/h   |
| 3           | 1        |  40.2 km/h   |
| 4           | 2        |  35.1 km/h   |
| 5           | 3        |  40 km/h   |
| 7           | 2        |  60 km/h   |
| 8          | 2        |  93.6 km/h   |
| 10           | 1        |  60 km/h   |

**7. What is the successful delivery percentage for each runner?**
````sql
SELECT
    runner_id,
    COUNT(pickup_time) as successful_deliveries,
    COUNT(order_id) as total_order,
    CAST(COUNT(pickup_time) as float) / COUNT(order_id) *100 as delivery_pct
from clean_runner_orders
GROUP BY
    runner_id
;
````
#### Steps:
- Simple **SELECT** statement.
- Simple division operation to find the percentage value.

#### Answer:
| runner_id | successful_deliveries | total_orders | delivery_pct |
| ----------- | ---------- |------------  | -----------------     |
| 1           | 4        |  4  | 100 |
| 2           | 3        |   4  | 75 |
| 3           | 1        |   2  |  50 |
