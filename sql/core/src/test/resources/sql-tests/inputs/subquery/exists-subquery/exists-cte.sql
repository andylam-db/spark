-- Tests EXISTS subquery used along with 
-- Common Table Expressions(CTE)

-- CTE used inside subquery with correlated condition
-- TC.01.01 
WITH bonus_cte 
     AS (SELECT * 
         FROM   subquery_bonus AS bonus 
         WHERE  EXISTS (SELECT dept.dept_id, 
                                 emp.emp_name, 
                                 Max(salary), 
                                 Count(*) 
                          FROM   subquery_emp AS emp 
                                 JOIN subquery_dept AS dept 
                                   ON dept.dept_id = emp.dept_id 
                          WHERE  bonus.emp_name = emp.emp_name 
                          GROUP  BY dept.dept_id, 
                                    emp.emp_name 
                          ORDER  BY emp.emp_name)) 
SELECT * 
FROM   subquery_bonus AS a
WHERE  a.bonus_amt > 30 
       AND EXISTS (SELECT 1 
                   FROM   bonus_cte b 
                   WHERE  a.emp_name = b.emp_name); 

-- Inner join between two CTEs with correlated condition
-- TC.01.02
WITH emp_cte 
     AS (SELECT * 
         FROM   subquery_emp AS emp 
         WHERE  id >= 100 
                AND id <= 300), 
     dept_cte 
     AS (SELECT * 
         FROM   subquery_dept AS dept 
         WHERE  dept_id = 10) 
SELECT * 
FROM   subquery_bonus AS a
WHERE  EXISTS (SELECT * 
               FROM   subquery_emp AS emp_cte a 
                      JOIN dept_cte b 
                        ON a.dept_id = b.dept_id 
               WHERE  bonus.emp_name = a.emp_name); 

-- Left outer join between two CTEs with correlated condition
-- TC.01.03
WITH emp_cte 
     AS (SELECT * 
         FROM   subquery_emp AS emp 
         WHERE  id >= 100 
                AND id <= 300), 
     dept_cte 
     AS (SELECT * 
         FROM   subquery_dept AS dept 
         WHERE  dept_id = 10) 
SELECT DISTINCT b.emp_name, 
                b.bonus_amt 
FROM   subquery_bonus AS b,
       emp_cte e, 
       subquery_dept AS dept d 
WHERE  e.dept_id = d.dept_id 
       AND e.emp_name = b.emp_name 
       AND EXISTS (SELECT * 
                   FROM   subquery_emp AS emp_cte a 
                          LEFT JOIN dept_cte b 
                                 ON a.dept_id = b.dept_id 
                   WHERE  e.emp_name = a.emp_name); 

-- Joins inside cte and aggregation on cte referenced subquery with correlated condition 
-- TC.01.04 
WITH empdept 
     AS (SELECT id, 
                salary, 
                emp_name, 
                dept.dept_id 
         FROM   subquery_emp AS emp 
                LEFT JOIN subquery_dept AS dept 
                       ON emp.dept_id = dept.dept_id 
         WHERE  emp.id IN ( 100, 200 )) 
SELECT emp_name, 
       Sum(bonus_amt) 
FROM   subquery_bonus AS bonus 
WHERE  EXISTS (SELECT dept_id, 
                      max(salary) 
               FROM   subquery_emp AS empdept 
               GROUP  BY dept_id 
               HAVING count(*) > 1) 
GROUP  BY emp_name; 

-- Using not exists 
-- TC.01.05      
WITH empdept 
     AS (SELECT id, 
                salary, 
                emp_name, 
                dept.dept_id 
         FROM   subquery_emp AS emp 
                LEFT JOIN subquery_dept AS dept 
                       ON emp.dept_id = dept.dept_id 
         WHERE  emp.id IN ( 100, 200 )) 
SELECT emp_name, 
       Sum(bonus_amt) 
FROM   subquery_bonus AS bonus 
WHERE  NOT EXISTS (SELECT dept_id, 
                          Max(salary) 
                   FROM   subquery_emp AS empdept 
                   GROUP  BY dept_id 
                   HAVING count(*) < 1) 
GROUP  BY emp_name; 
