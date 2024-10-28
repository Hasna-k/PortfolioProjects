USE hk;

CREATE TABLE employees_XML(
employee_id INT PRIMARY KEY auto_increment,
employee_name VARCHAR(50),
department VARCHAR(50),
salary DECIMAL(10,2),
hire_date date
);

SELECT * FROM employees_XML;

