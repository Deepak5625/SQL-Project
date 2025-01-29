-- Task 1: Customer Data Analysis
-- 1. Find the top 10 customers by credit limit
use modelcarsdb;
show tables;

select customerNumber,customerName,creditLimit from customers
order by creditLimit desc
limit 10;

-- 2. Find the average credit limit for customers in each country.
select country,avg(creditLimit) as average_creditLimit from customers
group by country;

-- 3. Find the number of customers in each state.
select state,count(*) as numberofcustomers from customers
group by state;

-- 4. Find the customers who haven't placed any orders.
select * from customers
where customerNumber not in (select customerNumber from orders);

-- 5. Calculate total sales for each customer.
select customerNumber,customerName,sum(quantityOrdered * priceEach) as TotalSales from customers 
join orders using (customerNumber)
join orderdetails using (orderNumber)
group by customerNumber, customername
order by customerNumber;
 

-- 6. List customers with their assigned sales representatives.
select customerNumber, concat(lastname, ' ', firstname) as salesrepresentative from customers 
join employees on salesrepemployeenumber = employeenumber;

-- 7. Retrieve customer information with their most recent payment details.
select customerName,date(paymentDate) from customers
left join payments using(customerNumber)
order by 2 desc;

-- 8.Identify the customers who have exceeded their credit limit.
select customerNumber,customerName,creditLimit,sum(amount) as TotalSales from customers 
join payments using (customerNumber)
group by customerNumber
having totalsales > creditLimit
order by customerNumber;

-- 9.Find the names of all customers who have placed an order for a product from a specific product line.
select distinct customername,productline from customers 
join orders using (customernumber)
join orderdetails using (ordernumber)
join products using (productcode)
where productline = 'classic cars'; 

-- 10. Find the names of all customers who have placed an order for the most expensive product.
select distinct customername from customers 
join orders  using (customernumber)
join orderdetails using (ordernumber)
join products using (productcode)
where buyprice= (select max(buyprice) from products);



-- Task 2: Office Data Analysis
-- 1. Count the number of employees working in each office.
select officeCode, count(*) as numberofemployees from employees
group by officeCode;

-- 2. Identify the offices with less than a certain number of employees.
select officeCode, count(*) as numberofemployees from employees
group by officeCode
having numberofemployees<3;

-- 3. List offices along with their assigned territories.
select * from offices
order by officeCode,territory;

-- 4. Find the offices that have no employees assigned to them.
select * from offices
left join employees using (officeCode)
where employeeNumber is null;

-- 5. Retrieve the most profitable office based on total sales.
select officecode, sum(quantityOrdered * priceEach) as totalSales from employees 
join customers on employees.employeeNumber = customers.salesRepEmployeeNumber
join orders using (customerNumber)
Join orderdetails using (orderNumber)
group by officecode
order by totalSales desc
limit 1;

-- 6. Find the office with the highest number of employees.
select officecode, count(*) as number_of_employees from employees
group by officecode
order by number_of_employees desc
limit 1;

-- 7. Find the average credit limit for customers in each office
select officecode, avg(creditlimit) as avg_credit_limit from employees e
join customers c on e.employeeNumber=c.salesRepEmployeeNumber
group by officecode
order by avg_credit_limit ;

-- 8. Find the number of offices in each country
select country,count(*) as numberofoffices from offices
group by country
order by numberofoffices desc;


-- Task 3: Product Data Analysis
-- 1. Count the number of products in each product line.
select productline,count(*) as numberofproducts from products
group by productline
order by numberofproducts desc;

-- 2.Find the product line with the highest average product price.
select productline,avg(buyprice) as averageprice from products
group by productline
order by averageprice desc
limit 1;

-- 3.Find all products with a price above or below a certain amount (MSRP should be between 50 and 100).
select * from products
where msrp between 50 and 100;

-- 4. Find the total sales amount for each product line.
select productline, sum(quantityordered * priceeach) as totalsales from products 
join orderdetails using (productcode)
group by productline
order by totalsales desc;

-- 5. Identify products with low inventory levels (less than a specific threshold value of 10 for quantityInStock).
select *from products
where quantityinstock < 10;

-- 6. Retrieve the most expensive product based on MSRP.
select productcode,productname,msrp from products
order by msrp desc
limit 1;

-- 7. Calculate total sales for each product.
select productcode, productname, sum(quantityordered * priceeach) as totalsales from products 
join orderdetails using (productcode)
group by productcode
order by totalsales desc;

-- 8. Identify the top selling products based on total quantity ordered using a stored procedure. 
-- The procedure should accept an input parameter to specify the number of top selling products to retrieve.*/
delimiter //
create procedure SP_GetTopSellingProducts(in top_selling_products int)
begin
    select productcode,productname,sum(quantityordered) as totalquantity from products 
    JOIN orderdetails using (productcode)
    group by productcode
    order by totalquantity desc
    limit top_selling_products;
end//
delimiter ;
call SP_GetTopSellingProducts(5);

-- 9.Retrieve products with low inventory levels (less than a threshold value of 10 for quantityInStock) 
-- within specific product lines ('Classic Cars', 'Motorcycles').
select * from products
where quantityinstock < 10 and productline in ('Classic Cars', 'Motorcycles');

-- 10. Find the names of all products that have been ordered by more than 10 customers.
select productname, count(*) from customers
join orders using  (customernumber) 
join orderdetails using (ordernumber)
join products using (productcode)
group by productname
having count(*) > 10 ;

-- 11. Find the names of all products that have been ordered more than the average number of orders for 
-- their product line

select productcode,productname,count(orderdetails.ordernumber) from products 
join orderdetails using (productcode)
group by productcode, productname, productline
having count(orderdetails.ordernumber) > ( select avg(orders) from
( select productline, count(orderdetails.ordernumber) as orders from products 
join orderdetails using (productcode) 
group by productline,productcode) as t
where t.productline=products.productline);