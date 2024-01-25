USE swiggy;
-- Find Customers who never ordered
SELECT *
FROM users
WHERE user_id NOT IN (SELECT user_id FROM orders); 

-- Average Price per Dish  
SELECT t1.f_id,AVG(price),f_name
FROM menu t1
JOIN food t2 ON t1.f_id=t2.f_id
GROUP BY f_id,f_name;

-- find top resturants in term of number of order for a given month 
SELECT t1.r_id,t2.r_name,COUNT(t1.r_id)
FROM orders t1
JOIN restaurants t2 ON t1.r_id=t2.r_id
WHERE MONTHNAME(date) LIKE 'June'
GROUP BY t1.r_id,t2.r_name
ORDER BY COUNT(t1.r_id) DESC
LIMIT 1;

-- resturants with monthly sales > x 
SELECT t1.r_id,r_name,MONTHNAME(date),SUM(amount) AS 'Sale'
FROM orders t1
JOIN restaurants t2 ON t1.r_id=t2.r_id
WHERE MONTHNAME(date) LIKE 'May' 
GROUP BY t1.r_id,r_name,MONTHNAME(date) HAVING Sale>700;

-- Show all orders with order details for a particular customer in a particular date range 
SELECT *
FROM orders t1
JOIN order_details t2 ON t1.order_id=t2.order_id
JOIN food t3 ON t2.f_id=t3.f_id
JOIN users t4 ON t1.user_id=t4.user_id
WHERE t1.user_id=1 AND date BETWEEN '2022-06-10'AND '2022-07-10';

-- find resturants with max repeated customers
SELECT t1.r_id,t2.r_name,COUNT(*) AS 'loyal_customers'
FROM (SELECT r_id,user_id,COUNT(user_id)
	  FROM swiggy.orders
      GROUP BY r_id,user_id HAVING COUNT(user_id)>1
      ORDER BY r_id) t1 
JOIN restaurants t2 ON t2.r_id=t1.r_id
GROUP BY t1.r_id,t2.r_name
ORDER BY loyal_customers DESC
LIMIT 1;

-- find most loyal customer of each resturant 


-- month over month revenue growth of swiggy  
SELECT Month,Revenue,((Revenue-prev)/prev)*100 AS 'Growth_Prcentage'
FROM(
WITH sales AS(
	SELECT MONTHNAME(date) AS 'Month',SUM(amount) AS 'Revenue'
	FROM swiggy.orders
	GROUP BY Month,MONTH(date)
	ORDER BY MONTH(date)
)
SELECT Month,Revenue,LAG(Revenue,1) OVER(ORDER BY Revenue) AS 'prev'
FROM sales
) t;


-- Customer Favourite Food
WITH temp AS 
(
	SELECT user_id,t2.f_id,COUNT(t2.f_id) AS 'Times_Ordered'
	FROM swiggy.order_details t1
	JOIN food t2 ON t1.f_id=t2.f_id
	JOIN orders t3 ON t1.order_id=t3.order_id
	GROUP BY user_id,t2.f_id
	ORDER BY user_id
)
SELECT *
FROM temp t1
JOIN food f
ON t1.f_id=f.f_id
WHERE t1.Times_ordered=(SELECT MAX(Times_ordered) FROM temp t2 WHERE t2.user_id=t1.user_id)
