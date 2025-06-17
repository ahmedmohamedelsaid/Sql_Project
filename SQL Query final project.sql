use final_project
go
--retrive table of products table
select *
from production.brands

select *
from production.categories

select *
from production.products


select *
from production.stocks
----retrive table of sales--
select*
from sales.customers

select*
from sales.order_items
select*
from sales.orders
select*
from sales.staffs
select*
from sales.stores


SELECT TOP 1 
    product_name, 
    list_price 
FROM production.products 
ORDER BY list_price DESC;


---1) Which bike is most expensive? What could be the motive behind pricing this bike at the high price? --
SELECT TOP 1 
    p.product_name, 
    p.list_price, 
    c.category_name
FROM production.products p
JOIN production.categories c 
    ON p.category_id = c.category_id
WHERE c.category_name LIKE '%Bike%' -- نحدد الفئات اللي تعتبر فعلاً دراجات
ORDER BY p.list_price DESC;
--2) How many total customers does BikeStore have?----
SELECT COUNT(*) AS total_customers 
FROM sales.customers;



---2)Would you consider people with order status 3 as customers substantiate your answer?--
SELECT COUNT(DISTINCT customer_id) AS rejected_customers
FROM sales.orders
WHERE order_status = 3;


---Would you consider people with order status 4 as customers substantiate your answer?--
SELECT COUNT(DISTINCT customer_id) AS active_customers
FROM sales.orders
WHERE order_status = 4;


---- 3) How many stores does BikeStore have? ---
select count( distinct s.store_id) BikeStores
from production.stocks  s
inner join  production.products p
on s.product_id=p.product_id
inner join production.categories c
on p.category_id=c.category_id
where c.category_name like '%Bike%'


---- 4) What is the total price spent per order? --
select  o.order_id,round(sum(o.list_price*o.quantity *(1-o.discount)),0) totalprice
from sales.order_items o
group by cube (o.order_id)
order by 1 



---the total spent for oreders--
SELECT 
    SUM(quantity * list_price * (1 - discount)) AS total_spent
FROM sales.order_items


--- 5) What’s the sales/revenue per store?--
select
    isnull(s.store_name, 'Total Revenue') AS store_name,round(SUM(quantity * list_price * (1 - discount)),0) AS total_revenue_forstore
from sales.order_items i
join sales.orders o
on i.order_id=o.order_id
join sales.stores s
on s.store_id=o.store_id
where o.order_status=4   ---the active order ony--
group by cube(s.store_name)
ORDER BY 2 ;


--6)  Which category is most sold?
select top(1) c.category_name,sum(i.quantity) totalprice
from production.categories c
inner join production.products  p
on  c.category_id=p.category_id
inner join sales.order_items i
on i.product_id=p.product_id
join sales.orders o
on i.order_id=o.order_id
join sales.stores s
on s.store_id=o.store_id
where o.order_status=4 
group by c.category_name
order by 2 desc


 --Which category is achive more revenue? --
select top(1) c.category_name,round(sum(i.list_price*i.quantity*(1-i.discount)),0) totalprice
from production.categories c
inner join production.products  p
on  c.category_id=p.category_id
inner join sales.order_items i
on i.product_id=p.product_id
join sales.orders o
on i.order_id=o.order_id
join sales.stores s
on s.store_id=o.store_id
where o.order_status=4 
group by c.category_name
order by 2 desc


----7) Which category rejected more orders? --
select  top(1)c.category_name, count( oi.quantity) totalrejected_order
from production.categories  c
join production.products  p
on c.category_id=p.category_id
join sales.order_items oi
on oi.product_id=p.product_id
join sales.orders o
on o.order_id=oi.order_id
where o.order_status=3
group by c.category_name
order by 2 desc


---8) Which bike is the least sold? --
select top(1) p.product_name , count(oi.quantity) #quantity
from   production.categories c
inner join production.products p
on c.category_id=p.category_id
inner join sales.order_items oi
on oi.product_id=p.product_id
inner join sales.orders o
on o.order_id=oi.order_id
where o.order_status=4 and c.category_name like '%Bikes'
group by  p.product_name
order by 2


----9) What’s the full name of a customer with ID 259? --
select concat(c.first_name,' ',c.last_name) fullname,c.customer_id
from sales.customers  c
where c.customer_id=259



--10) What did the customer on question 9 buy and when? What’s the status of this order? ---
select c.customer_id,concat(c.first_name,' ',c.last_name) fullname,p.product_name,oi.product_id,o.order_status
from sales.customers  c
inner join sales.orders o
on c.customer_id=o.customer_id
inner join sales.order_items oi
on oi.order_id=o.order_id
inner join production.products p
on p.product_id=oi.product_id
where c.customer_id=259


---11) Which staff processed the order of customer 259? And from which store? --
select  distinct (concat(s.first_name,' ',s.last_name)) fullname,ss.store_name
from sales.customers  c
inner join sales.orders o
on c.customer_id=o.customer_id
inner join sales.order_items oi
on oi.order_id=o.order_id
inner join sales.staffs s
on s.staff_id=o.staff_id
inner join sales.stores ss
on ss.store_id=o.store_id
where c.customer_id=259


--12) How many staff does BikeStore have? Who seems to be the lead Staff at BikeStore?--- 
select count(ss.staff_id) total_staff
from sales.staffs ss
select ss.staff_id,ss.first_name +' '+ss.last_name lead_staff_name,ss.email,s.store_name
from sales.staffs ss 
inner join sales.stores s
on ss.store_id=s.store_id
where ss.manager_id is null


---13) Which brand is the most liked?  best seller == most liked--
select top(1) p.product_name,sum(oi.quantity*oi.list_price*(1-oi.discount)) best_seller
from production.products p
inner join sales.order_items oi
on oi.product_id=p.product_id
inner join sales.orders o
on oi.order_id=o.order_id
where o.order_status=4
group by p.product_name
order by 2 desc


---14) How many categories does BikeStore have, and which one is the least liked?   least like= least sales --
select count(c.category_id) Number_of_BikeStore
from production.categories c
where c.category_name like'%Bikes%'

 
select top(1)c.category_name, sum(oi.list_price*oi.quantity*(1-oi.discount)) totalsales
from production.categories c
inner join production.products p
on c.category_id=p.category_id
inner join  sales.order_items oi
on oi.product_id=p.product_id
join sales.orders o
on oi.order_id=o.order_id
where o.order_status=4
group by c.category_name
order by 2


--15)  Which store still have more products of the most liked brand? --
select top(1) b.brand_id,b.brand_name,sum(oi.quantity*oi.list_price*(1-oi.discount)) as total_sold
from production.brands b
JOIN production.products p
on b.brand_id = p.brand_id
JOIN sales.order_items oi 
on oi.product_id = p.product_id
JOIN sales.orders o
on oi.order_id = o.order_id
where o.order_status= 4
group by b.brand_id, b.brand_name
order by total_sold DESC;

select
    st.store_id,st.store_name AS store_name,sum(stk.quantity) AS total_stock
from production.stocks stk
join production.products p ON stk.product_id = p.product_id
join production.brands b ON p.brand_id = b.brand_id
join sales.stores st ON stk.store_id = st.store_id
where b.brand_id = 9
group by st.store_id, st.store_name
order by total_stock DESC;


----16) Which state is doing better in terms of sales? --
select  top(1) c.state,round(sum(oi.quantity*oi.list_price*(1-oi.discount)),0) as total_sold
from sales.customers c 
inner join sales.orders o
on c.customer_id=o.customer_id
inner join sales.order_items oi
on oi.order_id=o.order_id
where o.order_status=4
group by c.state
order by 2


--17) What’s the discounted price of product id 259? --
select distinct p.product_name,oi.list_price,oi.discount,round(sum(oi.list_price*(1-discount)),1)  discount_price 
from production.products p
inner join sales.order_items oi
on oi.product_id=p.product_id
where p.product_id=259
group by p.product_name,oi.discount,oi.list_price


--18)  What’s the product name, quantity, price, category, model year and brand name of product number 44?--
select distinct p.product_name,oi.quantity,oi.list_price,c.category_name,p.model_year,b.brand_name
from production.products p
inner join sales.order_items oi
on oi.product_id=p.product_id
inner join production.brands b
on b.brand_id=p.brand_id
inner join production.categories c
on c.category_id=p.category_id
where p.product_id=44


--19) What’s the zip code of CA? -
select distinct c.state,c.street,c.zip_code
from sales.customers c
where c.state='CA'


--20) How many states does BikeStore operate in? --
SELECT COUNT(DISTINCT state) AS number_of_states
FROM sales.customers


---21) How many bikes under the children category were sold in the last 8 months? --
SELECT count(oi.quantity) as total_children_bikes_sold
FROM production.categories c
join production.products p 
on c.category_id = p.category_id
join sales.order_items oi 
on oi.product_id = p.product_id
join sales.orders o 
on oi.order_id = o.order_id
WHERE c.category_name LIKE '%Children%'
  and o.order_status = 4
  and o.order_date >= dateadd(month, -8, getdate());


  ---22) What’s the shipped date for the order from customer 523 --
  select c.first_name+' '+c.last_name full_name, o.shipped_date,o.order_status
  from sales.customers c
  inner join sales.orders o
  on o.customer_id=c.customer_id
  where c.customer_id=523


  ----23) How many orders are still pending? --
  select count(o.order_id) totals_of_pending_order
  from sales.orders  o
  where o.order_status=1


  --24) What’s the names of category and brand does "Electra white water 3i - 2018" fall under? --
select b.brand_id,c.category_name,p.product_name
from production.products  p
inner join production.categories c
on p.category_id=c.category_id
inner join production.brands b
on b.brand_id=p.brand_id
where p.product_name like ('%Electra white water 3i - 2018%')

