create database basic
use basic
select * from customer
select * from transactions
select * from prod_cat_info

-- 1 
select t.store_type as chan_of_tran from transactions as t
group by t.store_type
order by count(t.transaction_id) desc limit 1  

-- 2
select c.gender, count(c.customer_id) as total_cust from customer as c 
group by c.gender

-- 3
select c.city_code , count(c.customer_id) as total_cust from customer as c
group by c.city_code
order by count(c.customer_id) desc limit 1

-- 4
select p.prod_cat , count(p.prod_subcat) as number_sub_cat from prod_cat_info as p 
where p.prod_cat = 'books'
group by p.prod_cat

-- 5
select p.prod_cat, max(t.qty) as max_qnt  from transactions as t
join prod_cat_info as p 
on t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
group by p.prod_cat
order by max(t.qty) desc

-- 6 
select round(sum(t.total_amt)) as total_rev  from transactions as t
join prod_cat_info as p 
on t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
where p.prod_cat = 'books'or p.prod_cat = 'electronics'

-- 7 
select t.cust_id,count(t.transaction_id) as total_tran from transactions as t
where t.qty >0
group by t.cust_id
having count(t.transaction_id) > 10

-- 8
SELECT 
    ROUND(SUM(t.total_amt), 2) AS combined_revenue
FROM transactions AS t
JOIN prod_cat_info AS p 
    ON t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
WHERE p.prod_cat IN ('Electronics', 'Clothing')
  AND t.Store_type = 'Flagship store';

-- 9

SELECT 
    p.prod_subcat AS subcategory,
    ROUND(SUM(t.total_amt), 2) AS total_revenue
FROM transactions AS t
JOIN customer AS c 
    ON t.cust_id = c.customer_Id
JOIN prod_cat_info AS p 
    ON t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
WHERE 
    c.gender = 'M'
    AND p.prod_cat = 'Electronics'
GROUP BY 
    p.prod_subcat
ORDER BY 
    total_revenue DESC
LIMIT 5;


-- 10

select table_1.prod_subcat,sale_percent,sale_return_percent from
(select p.prod_subcat,round(count(t.transaction_id)/( select count(t.transaction_id) from transactions as t)*100,2) as sale_return_percent
from transactions as t 
join prod_cat_info as p
on t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
where t.qty < 0 
group by p.prod_subcat
order by round(count(t.transaction_id)/( select count(t.transaction_id) from transactions as t)*100,2) desc
 ) as table_1
right join
(select p.prod_subcat,round(count(t.transaction_id)/( select count(t.transaction_id) from transactions as t)*100,2) as sale_percent
from transactions as t 
join prod_cat_info as p
on t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
where t.qty > 0 
group by p.prod_subcat
order by round(count(t.transaction_id)/( select count(t.transaction_id) from transactions as t)*100,2) desc
limit 5) as table_2
on table_1.prod_subcat = table_2.prod_subcat

-- 11

select t_1.cust_id,age,revenue,tran_date from 
(select * from
(select a.cust_id,timestampdiff(year,a.dob,str_to_date(a.max_date,'%y-%m-%d')) as age , a.revenue from
(select t.cust_id,c.dob,max(t.tran_date) as max_date,round(sum(t.total_amt),2) as revenue from customer as c 
join transactions as t 
on t.cust_id = c.customer_id
where t.qty > 0
group by c.customer_id,c.dob
) as a
) as b
where b.age between 25 and 35) as t_1
join
(select t.cust_id,str_to_date(t.tran_date,'%d-%m-%Y') as tran_date from transactions as t 
group by t.cust_id,str_to_date(t.tran_date,'%d-%m-%Y')
having tran_date >= (SELECT DATE_ADD(MAX(STR_TO_DATE(tran_date, '%d-%m-%Y')), INTERVAL -30 DAY) AS cutoff_date FROM transactions)) as t_2
on t_1.cust_id = t_2.cust_id


 -- 12

SELECT 
    p.prod_cat,
    ROUND(SUM(ABS(t.total_amt)), 2) AS total_return_value
FROM 
    transactions AS t
JOIN 
    prod_cat_info AS p 
    ON t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
WHERE 
    STR_TO_DATE(t.tran_date, '%d-%m-%Y') BETWEEN (
        SELECT DATE_SUB(MAX(STR_TO_DATE(tran_date, '%d-%m-%Y')), INTERVAL 3 MONTH) 
        FROM transactions
    )
    AND (
        SELECT MAX(STR_TO_DATE(tran_date, '%d-%m-%Y')) FROM transactions
    )
    AND t.qty < 0
GROUP BY 
    p.prod_cat
ORDER BY 
    total_return_value DESC
LIMIT 1;


-- 13
select t.store_type,round(sum(t.total_amt),2) as total_amt,sum(t.qty) as total_quantity from transactions as t
group by t.store_type
order by round(sum(t.total_amt),2) desc limit 1

-- 14
select p.prod_cat,round(avg(total_amt),2) as avg_amt from transactions as t
join prod_cat_info as p 
on t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
group by p.prod_cat
having round(avg(total_amt),2) > (select avg(t.total_amt) from transactions as t )

-- 15

SELECT 
    p.prod_cat,
    p.prod_subcat,
    ROUND(AVG(t.total_amt), 2) AS avg_revenue,
    ROUND(SUM(t.total_amt), 2) AS total_revenue
FROM 
    transactions AS t
JOIN 
    prod_cat_info AS p 
    ON t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
JOIN (
    SELECT 
        p2.prod_cat
    FROM 
        transactions AS t2
    JOIN 
        prod_cat_info AS p2 
        ON t2.prod_cat_code = p2.prod_cat_code and t2.prod_subcat_code = p2.prod_sub_cat_code
    GROUP BY 
        p2.prod_cat
    ORDER BY 
        SUM(t2.qty) DESC
    LIMIT 5
) AS top5 ON p.prod_cat = top5.prod_cat
GROUP BY 
    p.prod_cat, p.prod_subcat
ORDER BY 
    p.prod_cat, total_revenue DESC;



