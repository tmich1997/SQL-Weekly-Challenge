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
- Using **JOIN** to get pricing data on a common field which would be the `product_id`.
- Using **GROUP BY** to aggregate as I only want it for each customer.

## Question and Solution

**1. How many pizzas were ordered?**