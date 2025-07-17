### 1. Create and Select the Database
CREATE DATABASE MyDataBase;
USE MyDataBase;

### 2. Create the Employees Table
CREATE TABLE employees (
	ID INT PRIMARY KEY,
    Full_Name VARCHAR(100),
    Salary DECIMAL(10,2)
);

ALTER TABLE employees ADD Age INT;

### 3. Insert Data into Employees Table
INSERT INTO employees(ID, Full_Name, Salary, Age) VALUES (1, 'Alice', 40000, 23);
INSERT INTO employees(ID, Full_Name, Salary, Age) VALUES (2, 'Sam', 47000, 23);
INSERT INTO employees(ID, Full_Name, Salary, Age) VALUES (3, 'Joel', 50000, 23);

### 4. Update Data in Employees Table
UPDATE employees SET Full_Name = 'Samuel' WHERE ID = 2;
UPDATE employees SET Salary = 43000 WHERE ID = 1;
UPDATE employees SET Age = 26 WHERE ID = 2;
UPDATE employees SET Age = 24 WHERE ID = 3;

### 5. Basic Select Queries
-- View all records
SELECT * FROM employees;

-- Select specific columns
SELECT Full_Name, Salary 
FROM employees;

-- Select employees with Salary > 45000
SELECT Full_Name, Salary 
FROM employees
WHERE Salary > 45000;

-- Salary > 45000 AND Age < 30
SELECT Full_Name, Salary 
FROM employees
WHERE Salary > 45000 AND Age < 30;

-- Salary > 45000 OR Age < 30
SELECT Full_Name, Salary 
FROM employees
WHERE Salary > 45000 OR Age < 30;

-- Names starting with 'A'
SELECT Full_Name 
FROM employees
WHERE Full_Name LIKE 'A%';

-- Rename column with alias
SELECT Full_Name AS Employee_Name
FROM employees
WHERE Salary > 45000;

-- Salary > 45000 and Age between 20 and 30
SELECT ID, Full_Name, Salary 
FROM employees
WHERE Salary > 45000 AND Age BETWEEN 20 AND 30;

### 6. Add and Update 'Department' Column
ALTER TABLE employees ADD Department TEXT;

-- Assign departments
UPDATE employees SET Department = 'Development' WHERE ID = 1;
UPDATE employees SET Department = 'Development' WHERE ID = 2;
UPDATE employees SET Department = 'HR' WHERE ID = 3;


### 7. Use of SQL Functions

-- Convert names to uppercase
SELECT ID, UPPER(Full_Name) AS UpperName
FROM employees;

-- Show increased salary (1.5x)
SELECT ID, Full_Name, Salary AS original_salary, ROUND(Salary * 1.5, 2) AS increased_salary
FROM employees;

### 8. Aggregate Functions and Grouping

-- total, average, max, min salaries
SELECT COUNT(*) AS Totalemployees,
	ROUND(AVG(Salary), 2) AS average__salary,
	MAX(Salary) AS maximum__salary,
	MIN(Salary) AS minimum__salary
FROM employees;

-- Group by Department
SELECT Department, COUNT(*) AS Dept_Count, ROUND(AVG(Salary), 2) AS avg_dept_salary
FROM employees
GROUP BY Department;

-- Group by with HAVING (only groups with 1 or fewer employees)
SELECT Department, COUNT(*) AS Dept_Count, ROUND(AVG(Salary), 2) AS avg_dept_salary
FROM employees
GROUP BY Department
HAVING COUNT(*) <= 1;

-- Department-wise total salary
SELECT Department, SUM(Salary) AS total_salary
FROM employees
GROUP BY Department;

### 9. Joins

-- Add Dept_ID to employees
ALTER TABLE employees ADD COLUMN Dept_ID INT;

-- Assign Dept_IDs
UPDATE employees SET Dept_ID = 1 WHERE Department = 'Development';
UPDATE employees SET Dept_ID = 2 WHERE Department = 'HR';

-- Check current data
SELECT * FROM employees;

-- Create Departments Table
CREATE TABLE Departments(
	ID INT PRIMARY KEY NOT NULL,
    Department_Name TEXT
);

-- Insert department data
INSERT INTO Departments VALUES (1,'Development'), (2,'HR');

-- View department data
SELECT * FROM Departments;

# 10. Joins Between Employees and Departments

-- LEFT JOIN: All employees and matching departments
SELECT E.ID, E.Full_Name, D.Department_Name
FROM employees AS E 
LEFT JOIN Departments AS D ON E.Dept_ID = D.ID;

-- RIGHT JOIN: All departments and matching employees
SELECT E.ID, E.Full_Name, D.Department_Name
FROM employees AS E 
RIGHT JOIN Departments AS D ON E.Dept_ID = D.ID;

-- CROSS JOIN: Every combination
SELECT E.Full_Name, D.Department_Name
FROM employees AS E 
CROSS JOIN Departments AS D;

