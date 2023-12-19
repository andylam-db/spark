-- Tests EXISTS subquery support. Tests basic form 
-- of EXISTS subquery (both EXISTS and NOT EXISTS)

-- uncorrelated exist query
-- TC.01.01
SELECT * 
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT 1 
               FROM   subquery_dept AS dept 
               WHERE  dept.dept_id > 10 
                      AND dept.dept_id < 30); 

-- simple correlated predicate in exist subquery
-- TC.01.02
SELECT * 
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT dept.dept_name 
               FROM   subquery_dept AS dept 
               WHERE  emp.dept_id = dept.dept_id); 

-- correlated outer isnull predicate
-- TC.01.03
SELECT * 
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT dept.dept_name 
               FROM   subquery_dept AS dept 
               WHERE  emp.dept_id = dept.dept_id 
                       OR emp.dept_id IS NULL);

-- Simple correlation with a local predicate in outer query
-- TC.01.04
SELECT * 
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT dept.dept_name 
               FROM   subquery_dept AS dept 
               WHERE  emp.dept_id = dept.dept_id) 
       AND emp.id > 200; 

-- Outer references (emp.id) should not be pruned from outer plan
-- TC.01.05
SELECT emp.emp_name 
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT dept.state 
               FROM   subquery_dept AS dept 
               WHERE  emp.dept_id = dept.dept_id) 
       AND emp.id > 200;

-- not exists with correlated predicate
-- TC.01.06
SELECT * 
FROM   subquery_dept AS dept 
WHERE  NOT EXISTS (SELECT emp_name 
                   FROM   subquery_emp AS emp 
                   WHERE  emp.dept_id = dept.dept_id);

-- not exists with correlated predicate + local predicate
-- TC.01.07
SELECT * 
FROM   subquery_dept AS dept 
WHERE  NOT EXISTS (SELECT emp_name 
                   FROM   subquery_emp AS emp 
                   WHERE  emp.dept_id = dept.dept_id 
                           OR state = 'NJ');

-- not exist both equal and greaterthan predicate
-- TC.01.08
SELECT * 
FROM   subquery_bonus AS bonus 
WHERE  NOT EXISTS (SELECT * 
                   FROM   subquery_emp AS emp 
                   WHERE  emp.emp_name = emp_name 
                          AND bonus_amt > emp.salary); 

-- select employees who have not received any bonus
-- TC 01.09
SELECT emp.*
FROM   subquery_emp AS emp
WHERE  NOT EXISTS (SELECT NULL
                   FROM   subquery_bonus AS bonus
                   WHERE  bonus.emp_name = emp.emp_name);

-- Nested exists
-- TC.01.10
SELECT * 
FROM   subquery_bonus AS bonus 
WHERE  EXISTS (SELECT emp_name 
               FROM   subquery_emp AS emp 
               WHERE  bonus.emp_name = emp.emp_name 
                      AND EXISTS (SELECT state 
                                  FROM   subquery_dept AS dept 
                                  WHERE  dept.dept_id = emp.dept_id)); 
