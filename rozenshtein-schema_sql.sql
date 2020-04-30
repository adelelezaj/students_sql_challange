-- Book by David Rozenshtein 
-- The Esence of SQL: A guide to learning most of SLQ in the least amount of time

CREATE DATABASE students;

drop table if exists student;
create table student (
  sno integer,
	sname varchar(10),
	age integer
);

drop table if exists courses;
create table courses (
	cno varchar(5),
	title varchar(10),
	credits integer
);

drop table if exists professor;
create table professor (
	lname varchar(10),
	dept varchar(10),
	salary integer,
	age integer
);

drop table if exists take;
create table take (
	sno integer,
	cno varchar(5)
);

drop table if exists teach;
create table teach (
	lname varchar(10),
	cno varchar(5)
);

insert into student values (1, 'AARON', 20);
insert into student values (2, 'CHUCK', 21);
insert into student values (3, 'DOUG', 20);
insert into student values (4, 'MAGGIE', 19);
insert into student values (5, 'STEVE', 22);
insert into student values (6, 'JING', 18);
insert into student values (7, 'BRIAN', 21);
insert into student values (8, 'KAY', 20);
insert into student values (9, 'GILLIAN', 20);
insert into student values (10, 'CHAD', 21);

insert into courses values ('CS112', 'PHYSICS', 4);
insert into courses values ('CS113', 'CALCULUS', 4);
insert into courses values ('CS114', 'HISTORY', 4);

insert into professor values ('CHOI', 'SCIENCE', 400, 45);
insert into professor values ('GUNN', 'HISTORY', 300, 60);
insert into professor values ('MAYER', 'MATH', 400, 55);
insert into professor values ('POMEL', 'SCIENCE', 500, 65);
insert into professor values ('FEUER', 'MATH', 400, 40);

insert into take values (1, 'CS112');
insert into take values (1, 'CS113');
insert into take values (1, 'CS114');
insert into take values (2, 'CS112');
insert into take values (3, 'CS112');
insert into take values (3, 'CS114');
insert into take values (4, 'CS112');
insert into take values (4, 'CS113');
insert into take values (5, 'CS113');
insert into take values (6, 'CS113');
insert into take values (6, 'CS114');

insert into teach values ('CHOI', 'CS112');
insert into teach values ('CHOI', 'CS112');
insert into teach values ('CHOI', 'CS112');
insert into teach values ('POMEL', 'CS113');
insert into teach values ('MAYER', 'CS112');
insert into teach values ('MAYER', 'CS114');

-- Q1: Who takes CS112?
SELECT sno
FROM take
WHERE cno ='CS112';

--Q2: Who takes course CS112 or CS114?
SELECT DISTINCT sno
FROM take
WHERE cno IN ('CS112', 'CS114');

 sno 
-----
   1
   2
   3
   4

--Q3: Who takes both CS112 and CS114?
SELECT sno
FROM take 
WHERE cno = 'CS112' OR cno='CS114'
GROUP BY 1
HAVING count(cno) = 2;

 sno 
-----
   1
   3
(2 rows)

-- Q4: Find all student names and student numbers for students who do not take CS112.

SELECT sno student_code, sname student_name
FROM student
WHERE sno NOT IN (
	SELECT sno
	FROM take 
	WHERE cno = 'CS112'
)
GROUP BY 1,2;

 student_code | student_name 
--------------+--------------
            5 | STEVE
            8 | KAY
            7 | BRIAN
            9 | GILLIAN
            6 | JING
           10 | CHAD
(6 rows)

-- Q5: Find all student numbers for students who take a course other than CS112

SELECT s.sno student_code
FROM student s
JOIN take t USING (sno)
WHERE t.cno != 'CS112'
GROUP by 1;

 student_code 
--------------
            1
            3
            4
            5
            6

-- Q6: Which students take at least three courses?

SELECT s.sname student_name
FROM student s
JOIN take t USING (sno)
GROUP BY 1
HAVING count(t.cno) >=3;

 student_name 
--------------
(0 rows)

-- Q7: Find students who take CS112 or CS114 but not both.

SELECT sno
FROM take
WHERE cno IN ('CS112', 'CS114') 
AND sno NOT IN (
  SELECT sno
  FROM take 
  WHERE cno = 'CS112' OR cno ='CS114'
  GROUP BY 1
  HAVING count(sno) = 2
) 
GROUP BY 1;

 sno 
-----
   2
   4
   6


-- Q8: Find the students who take exactly 2 courses

SELECT sno
FROM take
GROUP BY 1
HAVING count(*) = 2;

 sno 
-----
   3
   4
   6
(3 rows)

-- Q9: Find the students who take at most 2 courses.

SELECT sno
FROM take
GROUP BY 1
HAVING count(*) <= 2;

-- Q10: Find the students who take only CS112 and nothing else.

with students_with_1_course AS (
	SELECT s.sno, count(t.cno)
    FROM student AS s
	JOIN take as t USING (sno)
    GROUP BY 1
    HAVING count(t.cno) = 1
)
SELECT sno
FROM take
WHERE cno = 'CS112' AND sno IN (SELECT sno FROM students_with_1_course)
GROUP BY 1;

 sno 
-----
   2
(1 row)

-- Q11: Find the youngest students WITHOUT using MIN() or MAX().

SELECT sname, age
FROM student 
GROUP BY 1,2
ORDER BY age asc
LIMIT 1;

 sname | age 
-------+-----
 JING  |  18
(1 row)

--Q12: What are full names and ages of professors who teach CS112?

SELECT lname, age
FROM professor
JOIN teach USING (lname)
WHERE cno = 'CS112'
GROUP BY 1,2;

 lname | age 
-------+-----
 CHOI  |  45
 MAYER |  55

 --Q13: Who takes every course?

 SELECT sno, sname
 FROM student 
 JOIN take USING (sno)
 GROUP BY 1,2
 HAVING COUNT(cno) = (
   SELECT COUNT( distinct cno) FROM take
   );

 sno | sname 
-----+-------
   1 | AARON

-- For each department that has 2 professors older than 39, 
-- what is the average salary of such professors?

SELECT dept, ROUND(avg(salary))
FROM professor
WHERE age > 39
AND dept IN (
  SELECT dept
  FROM professor
  GROUP BY 1
  HAVING COUNT (lname) =2
)
GROUP BY 1;

-- What is the overall average salary of all professors older than 45?

SELECT round(avg(salary))
FROM professor
WHERE age>45;

 round 
-------
   400
  
-- Whose salary is greater than the average salary within that professor's department?
with avg_salary_per_dep AS (
  SELECT dept, round(avg(salary)) avg_salary
  FROM professor
  GROUP BY 1
)
SELECT a.dept, p.lname, a.avg_salary, p.salary
FROM professor as p
JOIN avg_salary_per_dep a USING (dept)
WHERE avg_salary < salary
GROUP BY 1,2,3,4;

  dept   | lname | avg_salary | salary 
---------+-------+------------+--------
 SCIENCE | POMEL |        450 |    500
