-- Tests EXISTS subquery support where the subquery is used outside the WHERE clause.


-- uncorrelated select exist
-- TC.01.01
SELECT
  emp_name,
  EXISTS (SELECT 1
          FROM   subquery_dept AS dept
          WHERE  dept.dept_id > 10
            AND dept.dept_id < 30)
FROM   subquery_emp AS emp;

-- correlated select exist
-- TC.01.02
SELECT
  emp_name,
  EXISTS (SELECT 1
          FROM   subquery_dept AS dept
          WHERE  emp.dept_id = dept.dept_id)
FROM   subquery_emp AS emp;

-- uncorrelated exist in aggregate filter
-- TC.01.03
SELECT
  sum(salary),
  sum(salary) FILTER (WHERE EXISTS (SELECT 1
                                    FROM   subquery_dept AS dept
                                    WHERE  dept.dept_id > 10
                                      AND dept.dept_id < 30))
FROM   subquery_emp AS emp;

-- correlated exist in aggregate filter
-- TC.01.04
SELECT
  sum(salary),
  sum(salary) FILTER (WHERE EXISTS (SELECT 1
                                    FROM   subquery_dept AS dept
                                    WHERE  emp.dept_id = dept.dept_id))
FROM   subquery_emp AS emp;

-- Multiple correlated exist in aggregate filter
-- TC.01.05
SELECT
    sum(salary),
    sum(salary) FILTER (WHERE EXISTS (SELECT 1
                                    FROM   subquery_dept AS dept
                                    WHERE  emp.dept_id = dept.dept_id)
                        OR EXISTS (SELECT 1
                                    FROM   subquery_bonus AS bonus
                                    WHERE  emp.emp_name = bonus.emp_name))
FROM   subquery_emp AS emp;

-- correlated exist in DISTINCT aggregate filter
-- TC.01.06
SELECT
    sum(DISTINCT salary),
    count(DISTINCT hiredate) FILTER (WHERE EXISTS (SELECT 1
                                    FROM   subquery_dept AS dept
                                    WHERE  emp.dept_id = dept.dept_id))
FROM   subquery_emp AS emp;

-- correlated exist in group by of an aggregate
-- TC.01.07
SELECT
    count(hiredate),
    sum(salary)
FROM   subquery_emp AS emp
GROUP BY EXISTS (SELECT 1
                FROM   subquery_dept AS dept
                WHERE  emp.dept_id = dept.dept_id);

-- correlated exist in group by of a distinct aggregate
-- TC.01.08
SELECT
    count(DISTINCT hiredate),
    sum(DISTINCT salary)
FROM   subquery_emp AS emp
GROUP BY EXISTS (SELECT 1
                 FROM   subquery_dept AS dept
                 WHERE  emp.dept_id = dept.dept_id);

-- uncorrelated exist in aggregate function
-- TC.01.09
SELECT
    count(CASE WHEN EXISTS (SELECT 1
                            FROM   subquery_dept AS dept
                            WHERE  dept.dept_id > 10
                              AND dept.dept_id < 30) THEN 1 END),
    sum(CASE WHEN EXISTS (SELECT 1
                          FROM   subquery_dept AS dept
                          WHERE  dept.dept_id > 10
                            AND dept.dept_id < 30) THEN salary END)
FROM   subquery_emp AS emp;

-- correlated exist in aggregate function
-- TC.01.10
SELECT
    count(CASE WHEN EXISTS (SELECT 1
                            FROM   subquery_dept AS dept
                            WHERE  emp.dept_id = dept.dept_id) THEN 1 END),
    sum(CASE WHEN EXISTS (SELECT 1
                          FROM   subquery_dept AS dept
                          WHERE  emp.dept_id = dept.dept_id) THEN salary END)
FROM   subquery_emp AS emp;

-- uncorrelated exist in window
-- TC.01.11
SELECT
    emp_name,
    sum(salary) OVER (PARTITION BY EXISTS (SELECT 1
                                           FROM   subquery_dept AS dept
                                           WHERE  dept.dept_id > 10
                                             AND dept.dept_id < 30))
FROM   subquery_emp AS emp;

-- correlated exist in window
-- TC.01.12
SELECT
    emp_name,
    sum(salary) OVER (PARTITION BY EXISTS (SELECT 1
                                           FROM   subquery_dept AS dept
                                           WHERE  emp.dept_id = dept.dept_id))
FROM   subquery_emp AS emp;
