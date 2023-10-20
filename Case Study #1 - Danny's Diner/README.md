# 🍜 Case Study #1: Danny's Diner

This is the beginning of my 8-Weeks of SQL challenge journey. I had a lot of fun and learned a lot expecially about CTE (common table expression), window fucntions, partition, order just to name a few.

If you feel inspired to learn SQL or want to challenge yourself you can find the challenges, [here](https://8weeksqlchallenge.com/case-study-1/).

## Initial Set-up
I am using VS Code as my IDE for this, and I used a SQL Server extension (downloaded from VS Code extensions) which will be used to then connect to the SQL server where you can then create the necessary tables for the task. To create the tables, you can just copy the CREATE command from the link provided earlier.

## The Task
Danny wants to use data answer some quesitons about his customers like: their spending habits, what they are buying, weather or not to expand the loyalty program.

## Question and Solution

**1. What is the total amount each customer spent at the restaurant?**

````sql
select
    s.customer_id,
    sum(m.price) as total_spend
from DannysDiner.dbo.sales s
join DannysDiner.dbo.menu m on s.product_id = m.product_id
group by s.customer_id;
````
#### Steps:
- Using **JOIN** to get pricing data on a common field which would be the `product_id`.
- Using **GROUP BY** to aggregate as I only want it for each customer.

#### Answer:
| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

**2. What is the total amount each customer spent at the restaurant?**