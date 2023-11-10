# 🍕 Case Study #2: Pizza Runner - Part A. Pizza Metrics

I am in my seond week of the 8-week SQL challenge. I had a lot of fun with Week 2. It was a lot more difficult, which is to be expected. Still, learned new things especially when it comes to clenaing the tables. The cleaning wasn't anything strenuous however, it is important to keep in mind that it is worthwhile to have a look at the table and the data in it to ensure that it is clean. 

I assumed that the tables were clean however, after checking some of the data types within the table I had to make adjustements to the table in order for the queries to work.

You can find the link for the seocnd challenge, [here](https://8weeksqlchallenge.com/case-study-2/).

You can find the solution to the first week, [here](https://github.com/tmich1997/SQL-Weekly-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/README.md?plain=1).

## Initial Set-up
I am using VS Code as my IDE for this, and I used a SQL Server extension (downloaded from VS Code extensions) which will be used to then connect to the SQL server where you can then create the necessary tables for the task. To create the tables, you can just copy the CREATE command from the link provided earlier.

## The Task
Danny wanted to expand his new pizza empire but pizza alone would not do it. He decided to hire "pizza runner" to deliver fresh pizzas. In addition to this he would collect data on the deliveries and want to use the data to optimise his operations.

## Data Cleaning
### Cleaning `customer_orders`
````sql
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
````
#### Steps:
- Cleaning the `customer_orders` table and renaming it to `clean_customer_orders`.
- Using **INSERT** and **SELECT** functions to get data from the original table and using **CASE** statement to modify the necessary fields to insert them into the new table.
- Original table had empty and null values.

### Cleaning `runner_orders`
````sql
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
````
#### Steps:
- Cleaning the `runner_orders` table and renaming it to `clean_runner_orders`.
- Similar steps to `customer_orders` used, like: **INSERT** and **SELECT** functions in the.
- Original table had empty and null values.
- It also had incosistent field values like: 10km, 10 km, and 10.
- New functions like **REPLACE** used to take care of the different variations in the field value as mentioned previously.

### Altering `pizza_names`
````sql
ALTER TABLE pizza_names
ALTER COLUMN pizza_name VARCHAR(50);
````

#### Steps:
- Altering `pizza_names` table.
- Changing the `pizza_name` field datatype to VARCHAR(50) from TEXT.
- Using the **ALTER** function.

## Question and Solution

**1. How many pizzas were ordered?**
````sql
SELECT
    count(order_id) as order_count
from PizzaRunner..customer_orders
;
````
#### Steps:
- Using a **COUNT** statment to calculate the number of pizzas ordered.

#### Answer:
| order_count|
| ----------- |
| 14          | 

**2. How many unique customer orders were made?**
````sql
SELECT
    COUNT(distinct order_id) as distinct_order
from PizzaRunner..customer_orders
;
````
#### Steps:
- Similar to the first question.
- Using a **DISTINCT** function to calculate.

#### Answer:
| distinct_order|
| ----------- |
| 10          | 

**3. How many successful orders were delivered by each runner?**
````sql
SELECT
    ro.runner_id,
    COUNT(ro.runner_id) as successful_orders
from PizzaRunner..runner_orders ro
where 
    ro.distance != 'null'
GROUP BY 
    ro.runner_id
;
````
#### Steps:
- Using **COUNT** for the number deliveries.
- Using **WHERE** as a filter to narrow it down to only the successful orders, in this case it is when the distance is `null`.
- **GROUP BY** to aggregate it to the `runner_id` level.

#### Answer:
| runner_id | successful_orders |
| ----------- | ----------- |
| 1           | 4           |
| 2           | 3           |
| 3           | 1           |

**4. How many of each type of pizza was delivered?**
````sql
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
````
#### Steps:
- Need to query thre different tables: `clean_runner_orders`, `pizza_names` and `customer_orders`.
- Using **JOIN** clause to join all the tables.
- Using **WHERE** as a filter to only include only the successful deliveries..
- Using **GROUP BY** to aggregate it to the `pizza_name` level.

#### Answer:
| Pizza_type | #_of_pizzas_deliveries |
| ----------- | ----------- |
| Meatlovers           | 9           |
| Vegetarian           | 3           |

**5. How many Vegetarian and Meatlovers were ordered by each customer?**
````sql
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
````
#### Steps:
- Using **COUNT** to count the numebr of orders.
- Using **JOIN** to get `pizza_name`.

#### Answer:
| customer_id | pizza_name | number_of_pizzas_ordered |
| ----------- | ---------- |------------  |
| 101           | Meatlovers        |  2   |
| 101           | Vegetarian        |  1   |
| 102           | Meatlovers        |  2   |
| 102           | Vegetarians        |  1   |
| 103           | Meatlovers        |  3   |
| 103           | Vegetarian        |  1   |
| 104           | Meatlovers        |  3   |
| 105           | Vegetarian        |  1   |

**6. What was the maximum number of pizzas delivered in a single order?**
````sql
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
````
#### Steps:
- Using **TOP 1** to find only the maximum number.

#### Answer:
| customer_id | order_id | pizza_count |
| ----------- | ---------- |------------  |
| 101           | 4        |  3   |

**7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**
````sql
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
````
#### Steps:
- Using **CASE** statments to check weather any changes were made.
- Changes include, any extras that were added or any exclusion that were made.
- Using **JOIN** so that other tables can be queried.

#### Answer:
| customer_id | no_change_in_pizza | change_in_pizza |
| ----------- | ---------- |------------  |
| 101           | 2        |  0   |
| 102           | 3        |  0   |
| 103           | 0        |  3   |
| 104           | 1        |  2   |
| 105           | 0        |  1   |

**8. How many pizzas were delivered that had both exclusions and extras?**
````sql
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
````
#### Steps:
- Similar to question 7.
- Using **CASE** statement to find which had both exclusion and extras.

#### Answer:
| customer_id | no_change_in_pizza |
| ----------- | ---------- |
| 101           | 0        |  
| 102           | 0        |  
| 103           | 0        |  
| 104           | 1        |  
| 105           | 0        |  

**9. What was the total volume of pizzas ordered for each hour of the day?**
````sql
SELECT
    count(cco.order_id) as pizza_count,
    datepart(hour, cco.order_time) as hour_of_day
from clean_customer_orders cco
GROUP BY
    datepart(hour, cco.order_time)
;
````
#### Steps:
- Using **DATEPART** to extract the hour from the `order_time` field.
- Using **GROUP BY** to aggregate it to the hour level.

#### Answer:
| pizza_count | hour_of_day |
| ----------- | ---------- |
| 1           | 11        |  
| 3           | 13        |  
| 3           | 18        |  
| 1           | 19        |  
| 3           | 21        |
| 3           | 23        |

**10. What was the volume of orders for each day of the week?**
````sql
SELECT
    count(cco.order_id) as pizza_count,
    DATENAME(DW, cco.order_time) as day_of_week
from clean_customer_orders cco
GROUP BY
    DATENAME(DW, cco.order_time)
;
````
#### Steps:
- Similar to question 10.
- Using **DATEPART** to extract the name of the day from the `order_time` field.
- Using **GROUP BY** to aggregate it to the day level.

#### Answer:
| pizza_count | day_of_week |
| ----------- | ---------- |
| 1           | Friday        |  
| 5           | Saturday        |  
| 3           | Thursday        |  
| 5           | Wednesday        |  

You can also download the SQL file - 'Week_2A_Pizza_Metrics.sql' - if you wish to as well, and the data cleaning file, 'Week_2A_Data_Cleaning.sql' as well.