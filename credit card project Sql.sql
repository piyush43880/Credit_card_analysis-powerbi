use credit_card;
 
-- 1.write a query to find city which had lowest percentage spend for gold card type

SELECT 
    city,
    SUM(amount) AS amount,
    (SUM(amount) / (SELECT 
            SUM(amount) 
        FROM
            credit
        WHERE
            card_type = 'gold')) * 100 AS gold_ratio
FROM
    credit
WHERE
    card_type = 'gold'
GROUP BY city
ORDER BY gold_ratio ASC
LIMIT 1;
   
   
-- 2.write a query to find percentage contribution of spends by females for each expense type.

 SELECT 
    *
FROM
    credit;
 with cte as(
  select exp_type, sum(amount)  as total
  from credit
   where gender="f"
   group by exp_type),
   cte1 as(
   select exp_type, sum(amount) as amt
    from   credit
     group  by  exp_type)
      select c.exp_type, concat(round(( amt-total)*100/amt ,2) ,"%")as percentage_contribution
       from cte as c
       inner join cte1 as c1
       on c.exp_type=c1.exp_type;
      
   
 -- 3.write a query to print highest spend month and amount spent in that month for each card type.
  with cte as(
  SELECT extract(year from transaction_date) as yt,
    EXTRACT(MONTH FROM transaction_date) AS months,
    card_type,
    SUM(amount) AS overall_month_spend
FROM
    credit
GROUP BY extract(year from transaction_date),
EXTRACT(MONTH FROM transaction_date) , card_type
 )
  select  yt, months, card_type, overall_month_spend  from  (
select *,
rank() over(partition by card_type order by overall_month_spend desc) as rn
 from cte) a
 where rn=1;
 
  
   
-- 4.write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends    
 
SELECT 
    city,
    MAX(amount) AS highest,
    SUM(amount) AS total,
 concat( round((  sum(amount) /(select sum(amount) from credit)) *100,2),"%") AS percentage_contribution
            
FROM
    credit
GROUP BY city
ORDER BY total DESC
LIMIT 5;
   
 -- 5. write a query to print the transaction details(all columns from the table) for each card type when
-- it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type).

with cte as(
select *,
sum(amount) over(partition by card_type  order by amount desc) as cumulative
 from credit)  
   select * from(
   select * ,
   rank() over(partition by card_type order by cumulative) as rn
   from cte
   where cumulative >=1000000) a
   where rn=1;
 
-- 6.which card and expense type combination saw highest month over month growth in Jan-2014.

with cte as 
(select  extract(year from transaction_date) as years ,extract(month from transaction_date) as months, card_type, exp_type , sum(amount) as total_month
 from credit
 group by extract(year from transaction_date), extract(month from transaction_date),card_type, exp_type),
 cte1 as(
 
  select *,
  lag(total_month) over(partition by card_type, exp_type order by years, months) as prev_month_total
  from cte),
  final as(
   select *, (total_month-prev_month_total)*100/prev_month_total as month_over_month_growth,
   row_number() over(  order by (total_month-prev_month_total)*100/prev_month_total desc) as rn
   from cte1
   where years=2014 and months=1)
    select * from final
    where rn=1;
 
 -- 7. write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type.
  with cte as
 ( select  city ,exp_type,  sum(amount) as amount from credit
   group by city, exp_type)
   
    select city,
   max( case when rn_desc=1 then  exp_type end ) as Highest_expense_type,
   min( case when rn_asc=1 then exp_type end )as Lowest_expense_type from(
    select city , exp_type,
    rank() over(partition by city order by amount asc) as rn_asc,
    rank() over(partition by city order by amount desc) as rn_desc
     from cte)a
     group by a.city;
    
     
 --  8. during weekends which city has highest total spend to total no of transcations ratio  
SELECT 
    city, SUM(amount) / COUNT(*) AS ratio
FROM
    credit
WHERE
    DAYNAME(transaction_date) IN ('saturday' , 'sunday')
GROUP BY city
ORDER BY ratio DESC
LIMIT 1;
   
-- 9.which city took least number of days to reach its 500th transaction after the first transaction in that city

with cte as(
select *,
 row_number() over(partition  by city order by transaction_date,  transaction_id) as rn
 from credit)
 
 
 select city , datediff(mn, ln) as no_of_days from (
  select city, min(transaction_date) as ln , max(transaction_date) as mn, rn
  from cte
  where rn =1 or rn=500
   group by city
    having  count(1)=2) a
    order by no_of_days asc
    limit 1;
    
    
   
    
 
 
 


 




   