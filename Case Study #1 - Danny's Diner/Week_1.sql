-- 1. What is the total amount each customer spent at the restaurant?
select
    s.customer_id,
    sum(m.price) as total_spend
from DannysDiner.dbo.sales s
join DannysDiner.dbo.menu m on s.product_id = m.product_id
group by s.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT 
    customer_id as customer,
    count(distinct(order_date)) as visit_count
from DannysDiner.dbo.sales
group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
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

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
    top 1 
    me.product_name,
    count(sa.product_id) as most_purchased 
from DannysDiner.dbo.sales sa
join DannysDiner.dbo.menu me
    on sa.product_id = me.product_id
group by me.product_name, sa.product_id
order by count(sa.product_id) DESC;

-- 5. Which item was the most popular for each customer?
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

-- 6. Which item was purchased first by the customer after they became a member?
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

-- 7. Which item was purchased just before the customer became a member?
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

-- 8. What is the total items and amount spent for each member before they became a member?
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

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- - how many points would each customer have?
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
GROUP by customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they 
-- earn 2x points on all items, not just sushi - 
-- how many points do customer A and B have at the end of January?