CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    manager_id INT
);
-- Create 'employees' table
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    hire_date DATE,
    job_title VARCHAR(50),
    department_id INT REFERENCES departments(id)
);

-- Create 'projects' table
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    start_date DATE,
    end_date DATE,
    department_id INT REFERENCES departments(id)
);

-- Insert data into 'departments'
INSERT INTO departments (name, manager_id)
VALUES ('HR', 1), ('IT', 2), ('Sales', 3);

-- Insert data into 'employees'
INSERT INTO employees (name, hire_date, job_title, department_id)
VALUES ('John Doe', '2018-06-20', 'HR Manager', 1),
       ('Jane Smith', '2019-07-15', 'IT Manager', 2),
       ('Alice Johnson', '2020-01-10', 'Sales Manager', 3),
       ('Bob Miller', '2021-04-30', 'HR Associate', 1),
       ('Charlie Brown', '2022-10-01', 'IT Associate', 2),
       ('Dave Davis', '2023-03-15', 'Sales Associate', 3);

-- Insert data into 'projects'
INSERT INTO projects (name, start_date, end_date, department_id)
VALUES ('HR Project 1', '2023-01-01', '2023-06-30', 1),
       ('IT Project 1', '2023-02-01', '2023-07-31', 2),
       ('Sales Project 1', '2023-03-01', '2023-08-31', 3);

-- disable safe update mode
SET SQL_SAFE_UPDATES=0;

-- execute update statement
UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'John Doe')
WHERE name = 'HR';

UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'Jane Smith')
WHERE name = 'IT';

UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'Alice Johnson')
WHERE name = 'Sales';

-- enable safe update mode
SET SQL_SAFE_UPDATES=1;



-- 1. Find the longest ongoing project for each department.
Select d.name as dept_name , p.name as projct_name , p.start_date,p.end_date,
datediff(p.end_date,p.start_date) as duration 
from projects p inner join departments d
ON d.id=p.department_id
order by 1 desc;

Select d.name as dept_name , p.name as projct_name , p.start_date,p.end_date,
timestampdiff(day,p.start_date,p.end_date) as duration 
from projects p inner join departments d
ON d.id=p.department_id
order by 1 desc;

-- 2.Find all employees who are not managers.
Select e.name from employees as e
where job_title not like '%manager%';

Select e.name from employees as e 
where id not in (select manager_id from departments);

-- 3 Find all employees who have been hired after the start of a project in their department.
Select e.name ,hire_date,p.start_Date 
from employees e inner join projects p
on p.department_id = e.department_id
where hire_date>p.start_date;

-- 4 Rank employees within each department based on their hire date (earliest hire gets the highest rank).
Select*,rank() over (partition by department_id order by hire_Date)
as rank_of_emp from employees;

-- 5 Find the duration between the hire date of each employee and
-- the hire date of the next employee hired in the same department.
With cte as 
(Select e.name as emp_name, d.name as dept_name ,e.hire_date as hiredate,
datediff(lead(e.hire_date) over (partition by department_id order by hire_Date) ,e.hire_Date)as duration 
from employees e join departments d
on d.id= e.department_id)
select emp_name,dept_name,hiredate,COALESCE(duration, 0) AS duration from cte;