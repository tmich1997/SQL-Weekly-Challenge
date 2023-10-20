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

**2. How many days has each customer visited the restaurant?**

````sql
SELECT 
    customer_id as customer,
    count(distinct(order_date)) as visit_count
from DannysDiner.dbo.sales
group by customer_id;
````

#### Steps:
- Using **COUNT DISTINCT** to get total number of visits.
- Using **GROUP BY** for aggregation.

#### Answer:
| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4           |
| B           | 6           |
| C           | 2           |

**3. What was the first item from the menu purchased by each customer?**

````sql
WITH first_item as (
    SELECT
        sa.customer_id,
        sa.product_id,
        DENSE_RANK() OVER(
            partition by sa.customer_id
            order by sa.order_date
        ) as rank
    from DannysDiner.dbo.sales sa
    group by sa.customer_id, sa.product_id, sa.order_date
)
SELECT
    fi.customer_id,
    me.product_name
from DannysDiner.dbo.menu me
join first_item fi on me.product_id = fi.product_id
where rank = 1;
````

#### Steps:
- Used CTE or Common Table expression which is essentially nested SQL queries. In this case the inner query is called `first_item` and once that is saved we can call it and query it
- We are also using a window function **DENSE_RANK()** which means there wont be any gaps inserted, it will go 1,2,3,4,4,4,5,6 and so on.
- Applying a filter with the **WHERE** clause.

#### Answer:
| customer_id | product_name | 
| ----------- | ----------- |
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

````sql
SELECT 
    top 1 
    me.product_name,
    count(sa.product_id) as most_purchased 
from DannysDiner.dbo.sales sa
join DannysDiner.dbo.menu me
    on sa.product_id = me.product_id
group by me.product_name, sa.product_id
order by count(sa.product_id) DESC;
````

#### Steps:
- Used **TOP** as I should only have one item
- Used **GROUP BY** for aggregation
- Sorted the list first using **DESC** then chose the top 1

#### Answer:
| product_name | most_purchased | 
| ----------- | ----------- |
| ramen          | 8        | 

**5. Which item was the most popular for each customer?**

````sql
WITH most_popular as (
    SELECT
        sa.customer_id as customer_id,
        me.product_name,
        count(sa.product_id) as order_count,
        DENSE_RANK() OVER(
            partition by sa.customer_id
            order by count(sa.product_id) desc) as rank
    from DannysDiner.dbo.sales sa
    join DannysDiner.dbo.menu me
        on me.product_id = sa.product_id
    group by sa.customer_id, me.product_name
)
select
    most_popular.customer_id, 
    most_popular.product_name, 
    most_popular.order_count
FROM most_popular 
WHERE rank = 1;
````

#### Steps:
- Using CTE with an inner query - `most_popular` doing most of the heavy lifting.
- Using a window function **DENSE_RANK** to apply a rank
- **WHERE** clause to filter only items with **RANK** 1.

#### Answer:
| customer_id | product_name | order_count |
| ----------- | ---------- |------------  |
| A           | ramen        |  3   |
| B           | sushi        |  2   |
| B           | curry        |  2   |
| B           | ramen        |  2   |
| C           | ramen        |  3   |

**6. Which item was purchased first by the customer after they became a member?**

````sql
WITH joined_as_member as (
    SELECT
        sa.order_date,
        sa.customer_id,
        me.product_name,
        ROW_NUMBER() OVER(
            partition  by sa.customer_id
            order by sa.order_date) as row_num
    from DannysDiner.dbo.sales sa
    join DannysDiner.dbo.menu me
        on me.product_id = sa.product_id
)
SELECT
    joined_as_member.customer_id,
    joined_as_member.product_name
from joined_as_member
join DannysDiner.dbo.members mem
    on mem.customer_id = joined_as_member.customer_id
where joined_as_member.order_date > mem.join_date
    and
row_num = 4;
````

#### Steps:
- Using CTE with an inner query - `joined_as_member` doing most of the heavy lifting.
- Using a window function **ROW_NUMBER()** to apply a row_number to each row.

#### Answer:
| customer_id | product_name |
| ----------- | ---------- |
| A           | ramen        |
| B           | sushi        |

**7. Which item was purchased just before the customer became a member?**

````sql
WITH item_purchase as (
    SELECT
        sa.product_id,
        mem.customer_id,
        ROW_NUMBER() OVER (
            partition by mem.customer_id
            order BY sa.order_date DESC) rank_num
    from DannysDiner.dbo.sales sa
    join DannysDiner.dbo.members mem
        ON mem.customer_id = sa.customer_id
        AND sa.order_date < mem.join_date
)
SELECT
    item_purchase.customer_id,
    me.product_name
from item_purchase
JOIN DannysDiner.dbo.menu me
    on me.product_id = item_purchase.product_id
where rank_num = 1;
````
#### Steps:
- Using CTE with an inner query - `item_purchase` doing most of the heavy lifting.
- Using a window function **ROW_NUMBER()** to apply a row_number to each row.

#### Answer:
| customer_id | product_name |
| ----------- | ---------- |
| A           | sushi        |
| B           | sushi        |

**8. What is the total items and amount spent for each member before they became a member?**

````sql
SELECT
    sa.customer_id,
    COUNT(sa.product_id) as total_items,
    SUM(me.price) as total_sales
from DannysDiner..sales sa
join DannysDiner..members mem
    on mem.customer_id = sa.customer_id
JOIN DannysDiner..menu me
    on me.product_id = sa.product_id
where sa.order_date < mem.join_date
GROUP by sa.customer_id;
````
#### Steps:
- Doing two **JOIN** clauses as information from all tables are required.
- Using **GROUP BY** for aggregation

#### Answer:
| customer_id | total_items | total_sales |
| ----------- | ---------- |----------  |
| A           | 2 |  25       |
| B           | 3 |  40       |

**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**

````sql
SELECT
    sa.customer_id,
    SUM(
        case
            when 
                mem.product_name = 'sushi'
            then
                mem.price * 20
            else
                mem.price * 10
        end
    ) as total_points
from DannysDiner..sales sa
JOIN DannysDiner..menu mem
    ON mem.product_id = sa.product_id
GROUP by sa.customer_id;
````
#### Steps:
- Using **SUM** for aggregating numeric values.
- Using **CASE** statements, which behave like **IF/ELSE** statements.
- Aggregating to the `customer_id` level.

#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 860 |
| B           | 940 |
| C           | 360 |

**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

````sql
SELECT
    sa.customer_id,
    SUM(
        mu.price * (case 
                        when mu.product_name = 'sushi'
                        then 20
                        when sa.order_date between mem.join_date and DATEADD(DAY, 6, mem.join_date)
                        then 20
                        ELSE 10
                    end)
    ) as points
from DannysDiner..sales sa
join DannysDiner..menu mu
    on mu.product_id = sa.product_id
join DannysDiner..members mem
    on sa.customer_id = mem.customer_id
where sa.order_date < DATEFROMPARTS(2021, 2, 1)
GROUP by sa.customer_id;
````
#### Steps:
- Using **SUM** and **CASE** statements to calculate the points.
- Useing **DATEADD()** to see if they are eligible for the 20 points from within the week.
- Aggregating to the `customer_id` level.
- Using **DATEFROMPARTS()** to calculate the points for the month of January.

#### Answer:
| customer_id | points | 
| ----------- | ---------- |
| A           | 1370 |
| B           | 820 |

**Bonus Question 1: Join all the Things**

````sql
SELECT
    s.customer_id,
    s.order_date,
    mu.product_name,
    mu.price,
    case
        when s.order_date >= mem.join_date then 'Y'
        when s.order_date < mem.join_date then 'N'
        else 'N'
    END as member
from DannysDiner..sales s
left JOIN DannysDiner..members mem
    on mem.customer_id = s.customer_id
join DannysDiner..menu mu
    on mu.product_id = s.product_id
ORDER BY s.customer_id, s.order_date;
````
#### Steps:
- Using a **CASE** statement to create another field called member.
- Doing a **LEFT JOIN** on the **members** table to capture all the members and the matching rows in the right table as well (**sales**).
- Using **ORDER BY** to order the table from ascending order of `customer_id` and `order date`.

#### Answer:
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | -------------| ----- | ------ |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

**Bonus Question 2: Rank all the Things**

````sql
with customer_data as (
SELECT
    s.customer_id,
    s.order_date,
    mu.product_name,
    mu.price,
    case
        when s.order_date >= mem.join_date then 'Y'
        when s.order_date < mem.join_date then 'N'
        else 'N'
    END as member
from DannysDiner..sales s
left JOIN DannysDiner..members mem
    on mem.customer_id = s.customer_id
join DannysDiner..menu mu
    on mu.product_id = s.product_id
)
SELECT 
    *,
    case 
        when cd.member = 'N' then null
        else RANK() OVER(
            partition by cd.customer_id, cd.member
            order BY cd.order_date
        )
    end as ranking
from customer_data cd;
````
#### Steps:
- Using CTE `customer_data` to create an inner query.
- Using the inner query to make a **CASE** statement for a new field **member**, this will check weather or they were a member in the loyalty program on the day they ordered food.
- Using a window function **RANK()** to rank every row based on a **PARTITION** of `customer_id` then `member`.

#### Answer:
| customer_id | order_date | product_name | price | member | ranking | 
| ----------- | ---------- | -------------| ----- | ------ |-------- |
| A           | 2021-01-01 | sushi        | 10    | N      | NULL
| A           | 2021-01-01 | curry        | 15    | N      | NULL
| A           | 2021-01-07 | curry        | 15    | Y      | 1
| A           | 2021-01-10 | ramen        | 12    | Y      | 2
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| B           | 2021-01-01 | curry        | 15    | N      | NULL
| B           | 2021-01-02 | curry        | 15    | N      | NULL
| B           | 2021-01-04 | sushi        | 10    | N      | NULL
| B           | 2021-01-11 | sushi        | 10    | Y      | 1
| B           | 2021-01-16 | ramen        | 12    | Y      | 2
| B           | 2021-02-01 | ramen        | 12    | Y      | 3
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-07 | ramen        | 12    | N      | NULL

You can also download the SQL file - 'Week_1.sql' if you wish to as well.