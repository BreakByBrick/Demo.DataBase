-- 1.1. Поиск клиента по id -- первичный ключ

-- 55.253 ms
EXPLAIN ANALYZE SELECT * FROM customers
WHERE customer_id = 145065;

-- добавление b-tree индекса
CREATE INDEX idx_customers_customer_id ON customers(customer_id);
-- DROP INDEX idx_customers_customer_id;

-- 0.132 ms
EXPLAIN ANALYZE SELECT * FROM customers
WHERE customer_id = 145065;

-- 1.2. Поиск заказов клиента по id -- внешний ключ

-- 2.127 ms
EXPLAIN ANALYZE SELECT * FROM orders
WHERE customer_id = 145065;

-- добавление b-tree индекса
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
-- DROP INDEX idx_orders_customer_id;

-- 0.084 ms
EXPLAIN ANALYZE SELECT * FROM orders
WHERE customer_id = 145065;

-- 1.3. Сортировка заказов клиента по id

-- 1365.637 ms
EXPLAIN analyze SELECT * FROM orders
order by order_id;

-- добавление b-tree индекса
CREATE INDEX idx_orders_order_id ON orders(order_id);
-- DROP INDEX idx_orders_order_id;

-- 810.151 ms
EXPLAIN analyze SELECT * FROM orders
order by order_id;

-- 1.4. Поиск по email, hash-индекс

-- 54.335 ms
EXPLAIN ANALYZE SELECT * FROM customers
WHERE email = 'customer_7565@example.com';

-- добавление хэш-индекса
CREATE INDEX idx_customers_hash_email ON customers USING HASH (email);
-- DROP INDEX idx_customers_hash_email;

-- 0.098 ms
EXPLAIN ANALYZE SELECT * FROM customers
WHERE email = 'customer_7565@example.com';

-- но операции сравнения не используют хэш-индекс, будут работать медленно
-- 763.027 ms
EXPLAIN ANALYZE SELECT * FROM customers
WHERE email > 'customer_75';

-- меняем хэш-индекс на b-tree
DROP INDEX idx_customers_hash_email;
CREATE INDEX idx_customers_email ON customers(email);
-- DROP INDEX idx_customers_email;

-- операция сравнения заработает быстро
-- 434.386 ms
EXPLAIN ANALYZE SELECT * FROM customers
WHERE email > 'customer_75';

-- 1.5. Поиск по тексту

-- 2372.039 ms
EXPLAIN ANALYZE SELECT *
FROM customers 
WHERE first_name like 'Customer_1%';

CREATE INDEX idx_customers_first_name ON customers(first_name);
-- DROP INDEX idx_customers_first_name;

EXPLAIN ANALYZE SELECT *
FROM customers 
WHERE first_name like 'Customer_1%';

-- добавление полнотекстового индекса
CREATE EXTENSION pg_trgm;
CREATE INDEX idx_customers_full_text_name ON customers  USING gin (first_name gin_trgm_ops);
-- DROP INDEX idx_customers_full_text_name;

-- 2. Есть индексы на соединяемых таблицах

EXPLAIN ANALYZE SELECT o.order_id, c.first_name 
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date = '2024-12-29';

CREATE INDEX idx_orders_order_date ON orders(order_date);
-- DROP INDEX idx_orders_order_date;

EXPLAIN ANALYZE SELECT o.order_id, c.first_name 
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date = '2024-12-29';

-- 3. Брать только нужные данные
EXPLAIN ANALYZE SELECT *
FROM orders o
where o.order_date > '2024-12-01';

EXPLAIN ANALYZE SELECT order_id
FROM orders o
where o.order_date > '2024-12-02';
