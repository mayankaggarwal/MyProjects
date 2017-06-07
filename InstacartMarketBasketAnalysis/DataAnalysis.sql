SELECT * FROM aisle;
SELECT * FROM departments;
SELECT * FROM order_products_prior;
SELECT * FROM order_products_train;
SELECT * FROM orders;
SELECT * FROM products;


SELECT o.user_id,o.eval_set,o.order_number
	/*,o.order_dow,o.order_hour_of_day,o.days_since_prior_order
	,case WHEN opt.order_id IS NULL THEN opp.order_id	ELSE opt.order_id END AS order_id*/
	,case WHEN opt.product_id IS NULL THEN opp.product_id ELSE opt.product_id END  AS product_id
	,case WHEN opt.add_to_cart_order IS NULL THEN opp.add_to_cart_order ELSE opt.add_to_cart_order END AS add_to_cart_order
	,case WHEN opt.reordered IS NULL THEN opp.reordered ELSE opt.reordered END AS reordered
	FROM order_products_prior opp 
	right outer join orders o on opp.order_id = o.order_id 
	left outer join order_products_train opt on o.order_id = opt.order_id
	where o.user_id = 1;


	SELECT o.user_id,o.eval_set,o.order_number
	,op.product_id
	,op.add_to_cart_order
	,op.reordered
	FROM orders o
	left outer join order_products op on o.order_id = op.order_id
	where o.user_id = 1;

SELECT count(*)
	,opp.product_id
	FROM order_products_prior opp 
	right outer join orders o on opp.order_id = o.order_id
	where o.user_id = 1 group by opp.product_id order by COUNT(*) desc;

SELECT * FROM orders where user_id = 1;

ALTER TABLE dbo.orders ADD PRIMARY KEY (order_id);


CREATE NONCLUSTERED INDEX idx_orders_orderid ON dbo.orders (order_id);
CREATE NONCLUSTERED INDEX idx_orders_userid ON dbo.orders (order_id);
CREATE NONCLUSTERED INDEX idx_opt_orderid ON dbo.order_products_prior (order_id);
CREATE NONCLUSTERED INDEX idx_opp_orderid ON dbo.order_products_train (order_id);

CREATE NONCLUSTERED INDEX idx_op_orderid ON dbo.order_products (order_id);

INSERT INTO order_products 
	SELECT * FROM order_products_train;

CREATE TABLE dbo.user_product_count
(
	user_id int,
	product_id int,
	ordered_count int
);

INSERT INTO dbo.user_product_count
	SELECT o.user_id,op.product_id,count(*) 
	FROM orders o
	left outer join order_products op on o.order_id = op.order_id
	group by user_id,op.product_id;
	



SELECT * FROM user_product_count order by user_id asc,ordered_count desc;
SELECT COUNT(DISTINCT(user_id)) FROM user_product_count where ordered_count>=3;
