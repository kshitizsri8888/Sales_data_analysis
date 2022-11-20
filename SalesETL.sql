create database Sales_Report
use Sales_Report


-- Data Extraction from excel source

select * from dbo.transactions
select * from dbo.customeraddress as ca
select * from dbo.customerlist as cl
select * from dbo.[cust_demographic] as cd
select * from dbo.long_lat as loc

--select brand, count(brand) as qty_sold from dbo.transactions
--where product_size = 'medium' 
--group by brand



--Date dim 

CREATE VIEW
Dim_Date AS
select distinct(cast (transaction_date as date)) as date_ 
from dbo.transactions

select * from dbo.Dim_Date  



--Product dim 

select distinct(product_id) as Product_ID , brand as Product_Name
from dbo.transactions
--group by product_id
order by product_id asc

select isnull(brand,'joe') as brand, count(customer_id) as customer_count
from transactions 
group by brand


select * from dbo.transactions

--checked for products that each brand have

select distinct(product_id) AS no_of_product,
isnull(brand,'joe') as brand from transactions
order by product_id

--due to each brand have same product id ,I concatinated the product_id and brand  to make a unique ID from product.

select  distinct(cast(product_id as int)) AS product_ID ,
concat(product_ID,brand) as product_key ,
isnull(brand,'joe') as brand
into ##unique_product
from transactions
order by product_id asc


select  distinct(cast(product_id as int)) AS product_ID ,
concat(product_ID,brand) as product_key ,
isnull(brand,'joe') as brand ,
product_class ,product_size
into ##unique_product1
from transactions
order by product_id asc

select * from ##unique_product1
order by brand asc

delete from ##unique_product1 where brand='joe'



--to execute temporary table easily in order by

select * from ##unique_product
order by product_ID


-- due to unneseary data type issue removed a row that had nulls
delete from ##unique_product where brand='joe' and product_key='0'

-- no. of products by each brand

select brand, count(product_key) as Prod_count
from ##unique_product
group by brand

-- Creating snowflake dimension of class and size attributes  using cross join and providing a key to link with dim_product_

create view  dim_Product
as
select brand ,concat(product_ID,brand,Left(product_class,1),left(product_size,1)) as product_uni_ID ,product_class,product_size
from transactions


select * from dim_Product


create view vclass
as
select distinct(product_class)
from dim_Product
where product_class is not Null

select * from  vclass


create view vsize 
as
select distinct(product_size)
from dim_Product
where product_size is not Null

select * from vsize

-- cross join
create view sf_class
as
select upper(concat(left(pc.product_class,1),left(ps.product_size,1))) as class_key ,pc.product_class,ps.product_size
from 
vclass pc cross join vsize ps 

select * from sf_class

Create view 
dim_product_
as
select  distinct(product_uni_ID) , brand,upper(right(product_uni_ID,2))as class_key
from dim_Product

select * from dim_product_




-- Trans_fact

create view fact_trans
as
select concat(t.product_ID,t.brand,Left(t.product_class,1),
left(t.product_size,1)) as product_uni_ID ,abs(t.list_price) as price,t.transaction_id,
t.transaction_date,t.customer_id,
upper(left(ca.country,2)) as location_key
from transactions t inner join customeraddress ca 
on t.customer_id=ca.customer_id


select * from fact_trans


-- dim_customer
create view
dim_customer as
select distinct(ca.customer_id),
concat(cd.first_name,' ',cd.last_name) as customer_name,
ca.postcode,
ca.country 
from customeraddress ca inner join cust_demographic cd
on  ca.customer_id = cd.customer_id

select * from dim_customer

-- dim_location

create view 
dim_location as
select * from dbo.long_lat as loc






































select * from dim_customer
select * from dim_product
select * from dim_location
select * from Dim_Date
select * from fact_trans











