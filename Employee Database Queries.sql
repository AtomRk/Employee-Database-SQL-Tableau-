Use employees_mod;
# Q1. Create a visualization that provides a breakdown between the male and female employees working in the company each year, starting from 1990.

SELECT 
    YEAR(d.from_date) AS calender_year,
    e.gender,
    COUNT(e.emp_no) AS count_of_employees
FROM
    t_employees e
        JOIN
    t_dept_emp d ON e.emp_no = d.emp_no
WHERE
    d.from_date >= '1990-01-01'
GROUP BY calender_year , e.gender
ORDER BY calender_year;

# Q2 Compare the number of male managers to the number of female managers from different departments for each year, starting from 1990.

SELECT 
    d.dept_name,
    de.emp_no,
    ee.gender,
    e.calender_year,
    de.from_date,
    de.to_date,
    (CASE
        WHEN e.calender_year BETWEEN YEAR(de.from_date) AND YEAR(de.to_date) THEN 1
        ELSE 0
    END) AS Active_Working
FROM
    (SELECT 
        YEAR(hire_date) AS calender_year
    FROM
        t_employees
    GROUP BY calender_year) AS e
        CROSS JOIN
    t_dept_manager de
        JOIN
    t_departments d ON de.dept_no = d.dept_no
        JOIN
    t_employees ee ON ee.emp_no = de.emp_no
ORDER BY de.emp_no , e.calender_year;

# Q3 Compare the average salary of female versus male employees in the entire company until year 2002, and add a filter allowing you to see that per each department.

SELECT 
    e.gender,
    d.dept_name,
    YEAR(s.from_date) calender_year,
    ROUND(AVG(s.salary), 2) AS average_salary
FROM
    t_salaries s
        JOIN
    t_employees e ON e.emp_no = s.emp_no
        JOIN
    t_dept_emp de ON e.emp_no = de.emp_no
        JOIN
    t_departments d ON d.dept_no = de.dept_no
WHERE
    YEAR(s.from_date) <= '2002'
GROUP BY gender , dept_name , calender_year
ORDER BY gender , dept_name , calender_year;

# Q4 Create an SQL stored procedure that will allow you to obtain the average male and female salary per department within a certain salary range. Let this range be defined by two values the user can insert when calling the procedure.

DROP PROCEDURE IF EXISTS a_salary;

DELIMITER $$

CREATE PROCEDURE a_salary (IN max_salary FLOAT, IN min_salary FLOAT)

BEGIN
	SELECT 
		e.gender, d.dept_name, AVG(s.salary) AS avg_salary
	FROM
		t_employees e
			JOIN
		t_salaries s ON s.emp_no = e.emp_no
			JOIN
		t_dept_emp de ON de.emp_no = e.emp_no
			JOIN
		t_departments d ON d.dept_no = de.dept_no
	WHERE
		s.salary BETWEEN min_salary AND max_salary
	GROUP BY e.gender , d.dept_name
	ORDER BY e.gender , d.dept_name , avg_salary;
END$$
DELIMITER ;
CALL employees_mod.a_salary(80000,75000);