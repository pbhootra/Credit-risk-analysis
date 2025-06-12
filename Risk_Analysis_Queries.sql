use CreditRisk_Data
select * from dbo.credit_accounts
select * from credit_data
select * from customer_risk
select * from loans
select * from transactions

--Which customers are using more than 90% of their credit limit
select a.customer_id,region,credit_exposure,b.credit_used,b.credit_limit,
(b.credit_used *100)/b.credit_limit as usage_per  from customer_risk a inner join 
credit_accounts b on  a.customer_id = b.customer_id 
where b.credit_used  >= .90*b.credit_limit

--Q2: Which customers made more than 2 high-value transactions (above ₹10,000) on the same day? 
select  customer_id,transaction_date ,count(*) as num_of_transactions from transactions 
where transaction_amount >10000 
Group by customer_id,transaction_date having count(*) >  2

--Q3: Find customers with 2 or more overdue loans in their last 2 loan transactions (use row number funtion for ranking) .
-- asssigned loans as rank as per the loan date
with ranked_loan as (select *,Row_number() over (partition by customer_id order by loan_date desc )as rn from loans )
select status, a.customer_id,region,count(*) as num_of_loans  from ranked_loan a 
inner join customer_risk b on a.customer_id = b.customer_id 
where status = 'Overdue' and rn>=2 group by a.customer_id ,status,region having count(*) >=2

--Q4: What regions have the highest average credit risk score? List top 2 riskiest customers per region.
with average_credit_risk_score as (select AVG(credit_risk_score) as avg_credit_risk_score , region  from customer_risk group by region)
select top 1 * from average_credit_risk_score order by avg_credit_risk_score desc

--List top 2 riskiest customers per region.
with customers_rank as ( select * , Row_number() over (partition by region order by credit_risk_score desc ) as rn from customer_risk )
select region , * from customers_rank a where rn < =2 order by a.region 