-- Creating a Customer Summary Report
-- In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database,
-- including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address,
-- and total number of rentals (rental_count).

CREATE VIEW customer_rental_information AS(
SELECT
	c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer AS c
JOIN rental AS r
ON c.customer_id = r.customer_id
GROUP BY c.customer_id);

SELECT *
FROM customer_rental_information;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the
-- rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE total_amount_by_customer AS(
SELECT
	cri.customer_id,
    SUM(p.amount) AS total_paid
FROM customer_rental_information AS cri
JOIN rental AS r
ON cri.customer_id = r.customer_id
JOIN payment AS p
ON r.rental_id = p.rental_id
GROUP BY cri.customer_id);

SELECT *
FROM total_amount_by_customer;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include
-- the customer's name, email address, rental count, and total amount paid.

WITH cte_summary_view AS (
SELECT 
	cri.customer_id,
	cri.first_name,
    cri.last_name,
    cri.email,
    cri.rental_count,
    tabc.total_paid
FROM total_amount_by_customer AS tabc
JOIN customer_rental_information AS cri
ON tabc.customer_id = cri.customer_id
)

SELECT
	customer_id,
	first_name,
    last_name
    email,
	rental_count,
    total_paid,
    round(AVG(total_paid/rental_count), 2) AS average_payment_per_rental
FROM cte_summary_view
GROUP BY customer_id, first_name, last_name, email, rental_count, total_paid;

-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email,
-- rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
