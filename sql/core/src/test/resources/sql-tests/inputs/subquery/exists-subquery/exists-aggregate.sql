-- Tests aggregate expressions in outer query and EXISTS subquery.

-- Test aggregate operator with codegen on and off.
--CONFIG_DIM1 spark.sql.codegen.wholeStage=true
--CONFIG_DIM1 spark.sql.codegen.wholeStage=false,spark.sql.codegen.factoryMode=CODEGEN_ONLY
--CONFIG_DIM1 spark.sql.codegen.wholeStage=false,spark.sql.codegen.factoryMode=NO_CODEGEN

-- Aggregate in outer query block.
-- TC.01.01
SELECT emp.dept_id, 
       avg(salary),
       sum(salary)
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT state 
               FROM   subquery_dept AS dept 
               WHERE  dept.dept_id = emp.dept_id) 
GROUP  BY dept_id; 

-- Aggregate in inner/subquery block
-- TC.01.02
SELECT emp_name 
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT max(dept.dept_id) a 
               FROM   subquery_dept AS dept 
               WHERE  dept.dept_id = emp.dept_id 
               GROUP  BY dept.dept_id); 

-- Aggregate expression in both outer and inner query block.
-- TC.01.03
SELECT count(*) 
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT max(dept.dept_id) a 
               FROM   subquery_dept AS dept 
               WHERE  dept.dept_id = emp.dept_id 
               GROUP  BY dept.dept_id); 

-- Nested exists with aggregate expression in inner most query block.
-- TC.01.04
SELECT * 
FROM   subquery_bonus AS bonus 
WHERE  EXISTS (SELECT 1 
               FROM   subquery_emp AS emp 
               WHERE  emp.emp_name = bonus.emp_name 
                      AND EXISTS (SELECT max(dept.dept_id) 
                                  FROM   subquery_dept AS dept 
                                  WHERE  emp.dept_id = dept.dept_id 
                                  GROUP  BY dept.dept_id));

-- Not exists with Aggregate expression in outer
-- TC.01.05
SELECT emp.dept_id, 
       Avg(salary), 
       Sum(salary) 
FROM   subquery_emp AS emp 
WHERE  NOT EXISTS (SELECT state 
                   FROM   subquery_dept AS dept 
                   WHERE  dept.dept_id = emp.dept_id) 
GROUP  BY dept_id; 

-- Not exists with Aggregate expression in subquery block
-- TC.01.06
SELECT emp_name 
FROM   subquery_emp AS emp 
WHERE  NOT EXISTS (SELECT max(dept.dept_id) a 
                   FROM   subquery_dept AS dept 
                   WHERE  dept.dept_id = emp.dept_id 
                   GROUP  BY dept.dept_id); 

-- Not exists with Aggregate expression in outer and subquery block
-- TC.01.07
SELECT count(*) 
FROM   subquery_emp AS emp 
WHERE  NOT EXISTS (SELECT max(dept.dept_id) a 
                   FROM   subquery_dept AS dept 
                   WHERE  dept.dept_id = emp.dept_id 
                   GROUP  BY dept.dept_id); 

-- Nested not exists and exists with aggregate expression in inner most query block.
-- TC.01.08
SELECT * 
FROM   subquery_bonus AS bonus 
WHERE  NOT EXISTS (SELECT 1 
                   FROM   subquery_emp AS emp 
                   WHERE  emp.emp_name = bonus.emp_name 
                          AND EXISTS (SELECT Max(dept.dept_id) 
                                      FROM   subquery_dept AS dept 
                                      WHERE  emp.dept_id = dept.dept_id 
                                      GROUP  BY dept.dept_id));

-- Window functions are not supported in EXISTS subqueries yet
SELECT *
FROM subquery_bonus AS bonus
WHERE EXISTS(SELECT RANK() OVER (PARTITION BY hiredate ORDER BY salary) AS s
                    FROM subquery_emp AS emp, subquery_dept AS DEPT where EMP.dept_id = DEPT.dept_id
                        AND DEPT.dept_name < BONUS.emp_name);
