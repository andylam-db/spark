-- Tests EXISTS subquery support. Tests Exists subquery
-- used in Joins (Both when joins occurs in outer and suquery blocks)

-- There are 2 dimensions we want to test
--  1. run with broadcast hash join, sort merge join or shuffle hash join.
--  2. run with whole-stage-codegen, operator codegen or no codegen.

--CONFIG_DIM1 spark.sql.autoBroadcastJoinThreshold=10485760
--CONFIG_DIM1 spark.sql.autoBroadcastJoinThreshold=-1,spark.sql.join.preferSortMergeJoin=true
--CONFIG_DIM1 spark.sql.autoBroadcastJoinThreshold=-1,spark.sql.join.forceApplyShuffledHashJoin=true

--CONFIG_DIM2 spark.sql.codegen.wholeStage=true
--CONFIG_DIM2 spark.sql.codegen.wholeStage=false,spark.sql.codegen.factoryMode=CODEGEN_ONLY
--CONFIG_DIM2 spark.sql.codegen.wholeStage=false,spark.sql.codegen.factoryMode=NO_CODEGEN

-- Join in outer query block
-- TC.01.01
SELECT * 
FROM   subquery_emp AS emp, 
       subquery_dept AS dept 
WHERE  emp.dept_id = dept.dept_id 
       AND EXISTS (SELECT * 
                   FROM   subquery_bonus AS bonus 
                   WHERE  bonus.emp_name = emp.emp_name); 

-- Join in outer query block with ON condition 
-- TC.01.02
SELECT * 
FROM   subquery_emp AS emp 
       JOIN subquery_dept AS dept 
         ON emp.dept_id = dept.dept_id 
WHERE  EXISTS (SELECT * 
               FROM   subquery_bonus AS bonus 
               WHERE  bonus.emp_name = emp.emp_name);

-- Left join in outer query block with ON condition 
-- TC.01.03
SELECT * 
FROM   subquery_emp AS emp 
       LEFT JOIN subquery_dept AS dept 
              ON emp.dept_id = dept.dept_id 
WHERE  EXISTS (SELECT * 
               FROM   subquery_bonus AS bonus 
               WHERE  bonus.emp_name = emp.emp_name); 

-- Join in outer query block + NOT EXISTS
-- TC.01.04
SELECT * 
FROM   subquery_emp AS emp, 
       subquery_dept AS dept 
WHERE  emp.dept_id = dept.dept_id 
       AND NOT EXISTS (SELECT * 
                       FROM   subquery_bonus AS bonus 
                       WHERE  bonus.emp_name = emp.emp_name); 


-- inner join in subquery.
-- TC.01.05
SELECT * 
FROM   subquery_bonus AS bonus 
WHERE  EXISTS (SELECT * 
                 FROM   subquery_emp AS emp 
                        JOIN subquery_dept AS dept 
                          ON dept.dept_id = emp.dept_id 
                 WHERE  bonus.emp_name = emp.emp_name); 

-- right join in subquery
-- TC.01.06
SELECT * 
FROM   subquery_bonus AS bonus 
WHERE  EXISTS (SELECT * 
                 FROM   subquery_emp AS emp 
                        RIGHT JOIN subquery_dept AS dept 
                                ON dept.dept_id = emp.dept_id 
                 WHERE  bonus.emp_name = emp.emp_name); 


-- Aggregation and join in subquery
-- TC.01.07
SELECT * 
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
                 ORDER  BY emp.emp_name);

-- Aggregations in outer and subquery + join in subquery
-- TC.01.08
SELECT emp_name, 
       Sum(bonus_amt) 
FROM   subquery_bonus AS bonus 
WHERE  EXISTS (SELECT emp_name, 
                        Max(salary) 
                 FROM   subquery_emp AS emp 
                        JOIN subquery_dept AS dept 
                          ON dept.dept_id = emp.dept_id 
                 WHERE  bonus.emp_name = emp.emp_name 
                 GROUP  BY emp_name 
                 HAVING Count(*) > 1 
                 ORDER  BY emp_name)
GROUP  BY emp_name; 

-- TC.01.09
SELECT emp_name, 
       Sum(bonus_amt) 
FROM   subquery_bonus AS bonus 
WHERE  NOT EXISTS (SELECT emp_name, 
                          Max(salary) 
                   FROM   subquery_emp AS emp 
                          JOIN subquery_dept AS dept 
                            ON dept.dept_id = emp.dept_id 
                   WHERE  bonus.emp_name = emp.emp_name 
                   GROUP  BY emp_name 
                   HAVING Count(*) > 1 
                   ORDER  BY emp_name) 
GROUP  BY emp_name;

-- Set operations along with EXISTS subquery
-- union
-- TC.02.01 
SELECT * 
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT * 
               FROM   subquery_dept AS dept 
               WHERE  dept_id < 30 
               UNION 
               SELECT * 
               FROM   subquery_dept AS dept 
               WHERE  dept_id >= 30 
                      AND dept_id <= 50); 

-- intersect 
-- TC.02.02 
SELECT * 
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT * 
                 FROM   subquery_dept AS dept 
                 WHERE  dept_id < 30 
                 INTERSECT 
                 SELECT * 
                 FROM   subquery_dept AS dept 
                 WHERE  dept_id >= 30 
                        AND dept_id <= 50);

-- intersect + not exists 
-- TC.02.03                
SELECT * 
FROM   subquery_emp AS emp 
WHERE  NOT EXISTS (SELECT * 
                     FROM   subquery_dept AS dept 
                     WHERE  dept_id < 30 
                     INTERSECT 
                     SELECT * 
                     FROM   subquery_dept AS dept 
                     WHERE  dept_id >= 30 
                            AND dept_id <= 50); 

-- Union all in outer query and except,intersect in subqueries. 
-- TC.02.04       
SELECT * 
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT * 
                 FROM   subquery_dept AS dept 
                 EXCEPT 
                 SELECT * 
                 FROM   subquery_dept AS dept 
                 WHERE  dept_id > 50)
UNION ALL 
SELECT * 
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT * 
                 FROM   subquery_dept AS dept 
                 WHERE  dept_id < 30 
                 INTERSECT 
                 SELECT * 
                 FROM   subquery_dept AS dept 
                 WHERE  dept_id >= 30 
                        AND dept_id <= 50);

-- Union in outer query and except,intersect in subqueries. 
-- TC.02.05       
SELECT * 
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT * 
                 FROM   subquery_dept AS dept 
                 EXCEPT 
                 SELECT * 
                 FROM   subquery_dept AS dept 
                 WHERE  dept_id > 50)
UNION
SELECT * 
FROM   subquery_emp AS emp 
WHERE  EXISTS (SELECT * 
                 FROM   subquery_dept AS dept 
                 WHERE  dept_id < 30 
                 INTERSECT 
                 SELECT * 
                 FROM   subquery_dept AS dept 
                 WHERE  dept_id >= 30 
                        AND dept_id <= 50);

-- Correlated predicates under set ops - unsupported
SELECT *
FROM   subquery_emp AS emp
WHERE  EXISTS (SELECT *
               FROM   subquery_dept AS dept
               WHERE  dept_id = emp.dept_id and state = "CA"
               UNION
               SELECT *
               FROM   subquery_dept AS dept
               WHERE  dept_id = emp.dept_id and state = "TX");

SELECT *
FROM   subquery_emp AS emp
WHERE NOT EXISTS (SELECT *
               FROM   subquery_dept AS dept
               WHERE  dept_id = emp.dept_id and state = "CA"
               UNION
               SELECT *
               FROM   subquery_dept AS dept
               WHERE  dept_id = emp.dept_id and state = "TX");

SELECT *
FROM   subquery_emp AS emp
WHERE  EXISTS (SELECT *
               FROM   subquery_dept AS dept
               WHERE  dept_id = emp.dept_id and state = "CA"
               INTERSECT ALL
               SELECT *
               FROM   subquery_dept AS dept
               WHERE  dept_id = emp.dept_id and state = "TX");

SELECT *
FROM   subquery_emp AS emp
WHERE EXISTS (SELECT *
               FROM   subquery_dept AS dept
               WHERE  dept_id = emp.dept_id and state = "CA"
               INTERSECT DISTINCT
               SELECT *
               FROM   subquery_dept AS dept
               WHERE  dept_id = emp.dept_id and state = "TX");

SELECT *
FROM   subquery_emp AS emp
WHERE  EXISTS (SELECT *
               FROM   subquery_dept AS dept
               WHERE  dept_id = emp.dept_id and state = "CA"
               EXCEPT ALL
               SELECT *
               FROM   subquery_dept AS dept
               WHERE  dept_id = emp.dept_id and state = "TX");

SELECT *
FROM   subquery_emp AS emp
WHERE  EXISTS (SELECT *
               FROM   subquery_dept AS dept
               WHERE  dept_id = emp.dept_id and state = "CA"
               EXCEPT DISTINCT
               SELECT *
               FROM   subquery_dept AS dept
               WHERE  dept_id = emp.dept_id and state = "TX");

SELECT *
FROM   subquery_emp AS emp
WHERE NOT EXISTS (SELECT *
               FROM   subquery_dept AS dept
               WHERE  dept_id = emp.dept_id and state = "CA"
               INTERSECT ALL
               SELECT *
               FROM   subquery_dept AS dept
               WHERE  dept_id = emp.dept_id and state = "TX");

SELECT *
FROM   subquery_emp AS emp
WHERE NOT EXISTS (SELECT *
               FROM   subquery_dept AS dept
               WHERE  dept_id = emp.dept_id and state = "CA"
               EXCEPT DISTINCT
               SELECT * 
               FROM   subquery_dept AS dept 
               WHERE  dept_id = emp.dept_id and state = "TX");
