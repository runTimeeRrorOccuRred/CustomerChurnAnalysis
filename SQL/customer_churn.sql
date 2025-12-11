-- churned vs non_churned customers
select * from customer_churn
select churn, count(*) from customer_churn
group by Churn

--churn rate by contract type
select contract,
sum(case when churn='yes' then 1 else 0 end) as 'churned',
concat(cast(sum(case when churn='yes' then 1.0 else 0 end)*100/count(*)
as decimal (10,2)),'%') as 'churned rate'
from customer_churn
group by Contract

--average monthly charges by internet service
select internetservice, cast(avg(monthlycharges) as decimal (10,2))
as 'Average Monthly Charges' from customer_churn
group by InternetService
order by avg(MonthlyCharges) desc


--churn rate by senior citizen
select seniorcitizen,
sum(case when churn='yes' then 1 else 0 end) as 'churned',
cast(sum(case when churn='yes' then 1.0 else 0 end)*100/count(*)
as decimal(10,2)) as 'churned rate'
from customer_churn
group by seniorcitizen
order by 3 desc

--average tenure of churned vs non-churned customers
select churn, cast(avg(cast(tenure as decimal(10,2))) as decimal(10,2))
as 'average tenure' from customer_churn
group by churn
order by 2 desc

--top 3 payment method with highest churn rate
with cte as (
select paymentmethod,
concat(cast(sum(case when churn='yes' then 1.0 else 0 end)*100/count(*) as decimal(10,2)),'%')
as 'churned rate',
dense_rank() over (order by 
cast(sum(case when churn='yes' then 1.0 else 0 end)*100/count(*) as decimal(10,2)) desc) as 'rank'
from customer_churn
group by PaymentMethod)

select * from cte 
where rank <=3

--correlation check monthly charges and tenure
select cast((avg(monthlycharges*tenure)-(avg(monthlycharges)*avg(tenure)))/
(STDEV(monthlycharges)*STDEV(tenure)) as decimal(10,2)) as 'correlation'
from customer_churn

--churn rate by multiple services
select 
case when phoneservice='yes' and internetservice in ('Dsl','Fiber Optic') then 'both'
when PhoneService='yes' and InternetService='No' then 'phone service'
when phoneservice='no' and internetservice in ('Dsl','Fiber optic') then 'internet service'
end as 'Multiple services',
cast(sum(case when churn='yes' then 1.0 else 0 end)*100/count(*) as decimal(10,2)) as 'churned rate'
from customer_churn
group by
case when phoneservice='yes' and internetservice in ('Dsl','Fiber Optic') then 'both'
when PhoneService='yes' and InternetService='No' then 'phone service'
when phoneservice='no' and internetservice in ('Dsl','Fiber optic') then 'internet service'
end
order by 2 desc

--monthly revenue lost due to churn
select 
cast(sum(case when churn='yes' then monthlycharges else 0 end)
as decimal(10,2)) as 'lost monthly charges'
from customer_churn

--year over year or tenure based growth in customers
select tenure,count(customerID) as 'current tenure customers',
lag(count(customerID),1) over(order by tenure asc) as 'previous tenure customers',
cast((cast(count(customerID) as decimal(10,2))-lag((cast(count(customerID) as decimal(10,2))),1)
over(order by tenure asc))*100
/lag((cast(count(customerID) as decimal(10,2))),1) over(order by tenure asc) as decimal(10,2))
as 'tenure based growth'
from customer_churn
group by tenure

--customers having all online services active
select
sum(case when Onlinesecurity='yes' and onlinebackup='yes' and deviceprotection='yes'
and techsupport='yes' and streamingtv='yes' and streamingmovies='yes' then 1 else 0 end)
as 'Online service customers'
from customer_churn

--identify high value customers at risk

select * from customer_churn
where
churn='no' and
contract='month-to-month' and
SeniorCitizen='yes' and
(OnlineSecurity='no' or techsupport='no') and
InternetService='fiber optic' and
PaperlessBilling='yes' and
Partner='no' and
PaymentMethod='electronic check' and
tenure>(select avg(tenure) from customer_churn) and
totalcharges>(select avg(totalcharges) from customer_churn)


