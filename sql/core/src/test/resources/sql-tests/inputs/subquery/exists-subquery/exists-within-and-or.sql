-- Tests EXISTS subquery support. Tests EXISTS 
-- subquery within a AND or OR expression.


-- Or used in conjunction with exists - ExistenceJoin
-- TC.02.01
SELECT emp.emp_name 
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT dept.state 
               FROM   subquery_dept AS dept 
               WHERE  emp.dept_id = dept.dept_id) 
        OR emp.id > 200;

-- all records from subquery_emp AS emp including the null dept_id 
-- TC.02.02
SELECT * 
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT dept.dept_name 
               FROM   subquery_dept AS dept 
               WHERE  emp.dept_id = dept.dept_id) 
        OR emp.dept_id IS NULL; 

-- EXISTS subquery in both LHS and RHS of OR. 
-- TC.02.03
SELECT emp.emp_name 
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT dept.state 
               FROM   subquery_dept AS dept 
               WHERE  emp.dept_id = dept.dept_id 
                      AND dept.dept_id = 20) 
        OR EXISTS (SELECT dept.state 
                   FROM   subquery_dept AS dept 
                   WHERE  emp.dept_id = dept.dept_id 
                          AND dept.dept_id = 30); 
;

-- not exists and exists predicate within OR
-- TC.02.04
SELECT * 
FROM   subquery_bonus AS bonus 
WHERE  ( NOT EXISTS (SELECT * 
                     FROM   subquery_emp AS emp 
                     WHERE  emp.emp_name = emp_name 
                            AND bonus_amt > emp.salary) 
          OR EXISTS (SELECT * 
                     FROM   subquery_emp AS emp 
                     WHERE  emp.emp_name = emp_name 
                             OR bonus_amt < emp.salary) );

-- not exists and in predicate within AND
-- TC.02.05
SELECT * FROM subquery_bonus AS bonus WHERE NOT EXISTS 
( 
       SELECT * 
       FROM   subquery_emp AS emp 
       WHERE  emp.emp_name = emp_name 
       AND    bonus_amt > emp.salary) 
AND 
emp_name IN 
( 
       SELECT emp_name 
       FROM   subquery_emp AS emp 
       WHERE  bonus_amt < emp.salary);

