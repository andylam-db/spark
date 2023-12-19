-- Tests HAVING clause in subquery.

-- simple having in subquery.
-- TC.01.01
SELECT dept_id, count(*) 
FROM   subquery_emp AS emp 
GROUP  BY dept_id 
HAVING EXISTS (SELECT 1 
               FROM   subquery_bonus AS bonus 
               WHERE  bonus_amt < min(emp.salary)); 

-- nested having in subquery
-- TC.01.02
SELECT * 
FROM   subquery_dept AS dept 
WHERE  EXISTS (SELECT dept_id, 
                      Count(*) 
               FROM   subquery_emp AS emp 
               GROUP  BY dept_id 
               HAVING EXISTS (SELECT 1 
                              FROM   subquery_bonus AS bonus 
                              WHERE bonus_amt < Min(emp.salary)));

-- aggregation in outer and inner query block with having
-- TC.01.03
SELECT dept_id, 
       Max(salary) 
FROM   subquery_emp AS gp
WHERE  EXISTS (SELECT dept_id, 
                      Count(*) 
               FROM   subquery_emp AS emp p
               GROUP  BY dept_id 
               HAVING EXISTS (SELECT 1 
                              FROM   subquery_bonus AS bonus 
                              WHERE  bonus_amt < Min(p.salary))) 
GROUP  BY gp.dept_id;

-- more aggregate expressions in projection list of subquery
-- TC.01.04
SELECT * 
FROM   subquery_dept AS dept 
WHERE  EXISTS (SELECT dept_id, 
                        Count(*) 
                 FROM   subquery_emp AS emp 
                 GROUP  BY dept_id 
                 HAVING EXISTS (SELECT 1 
                                FROM   subquery_bonus AS bonus 
                                WHERE  bonus_amt > Min(emp.salary)));

-- multiple aggregations in nested subquery
-- TC.01.05
SELECT * 
FROM   subquery_dept AS dept 
WHERE  EXISTS (SELECT dept_id, 
                      count(emp.dept_id)
               FROM   subquery_emp AS emp 
               WHERE  dept.dept_id = dept_id 
               GROUP  BY dept_id 
               HAVING EXISTS (SELECT 1 
                              FROM   subquery_bonus AS bonus 
                              WHERE  ( bonus_amt > min(emp.salary) 
                                       AND count(emp.dept_id) > 1 )));
