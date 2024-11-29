SELECT * FROM bonus

INSERT INTO Worker 
    (WORKER_ID, FIRST_NAME, LAST_NAME, SALARY, JOINING_DATE, DEPARTMENT) VALUES
        (101, 'John', 'Doe', 80000, '2022-01-15 09:00:00', 'IT'),
        (102, 'Jane', 'Smith', 70000, '2022-02-20 10:30:00', 'Finance'),
        (103, 'Michael', 'Johnson', 90000, '2022-03-10 08:45:00', 'HR'),
        (104, 'Emily', 'Williams', 75000, '2022-04-05 11:15:00', 'Marketing'),
        (105, 'William', 'Brown', 85000, '2022-05-12 09:30:00', 'IT'),
        (106, 'Olivia', 'Jones', 72000, '2022-06-18 10:00:00', 'Finance'),
        (107, 'Daniel', 'Clark', 95000, '2022-07-22 08:15:00', 'HR'),
        (108, 'Sophia', 'Taylor', 78000, '2022-08-28 11:45:00', 'Marketing');


	
CREATE TABLE Bonus (
    WORKER_REF_ID INT,
    BONUS_AMOUNT INT,
    BONUS_DATE TIMESTAMP,
    FOREIGN KEY (WORKER_REF_ID)
        REFERENCES Worker(WORKER_ID)
        ON DELETE CASCADE
);


INSERT INTO Bonus 
    (WORKER_REF_ID, BONUS_AMOUNT, BONUS_DATE) VALUES
        (101, 5000, '2022-02-16 14:00:00'),
        (102, 3000, '2022-03-20 13:30:00'),
        (103, 4000, '2022-04-25 16:45:00'),
        (101, 4500, '2022-05-30 12:15:00'),
        (102, 3500, '2022-06-28 15:00:00');

CREATE TABLE Title (
    WORKER_REF_ID INT,
    WORKER_TITLE CHAR(25),
    AFFECTED_FROM TIMESTAMP,
    FOREIGN KEY (WORKER_REF_ID)
        REFERENCES Worker(WORKER_ID)
        ON DELETE CASCADE
);

INSERT INTO Title 
    (WORKER_REF_ID, WORKER_TITLE, AFFECTED_FROM) VALUES
    (101, 'Manager', '2022-01-20 00:00:00'),
    (102, 'Executive', '2022-02-15 00:00:00'),
    (108, 'Executive', '2022-02-15 00:00:00'),
    (105, 'Manager', '2022-02-15 00:00:00'),
    (104, 'Asst. Manager', '2022-02-15 00:00:00'),
    (107, 'Executive', '2022-02-15 00:00:00'),
    (106, 'Lead', '2022-02-15 00:00:00'),
    (103, 'Lead', '2022-02-15 00:00:00');

--This is the start of the task, bear in mind I used Postgresql 
--so there would be some commands that are different


--Q1
SELECT first_name As Worker_Name from worker 

--Q2
SELECT UPPER(first_name) As first_name from worker

--Q3
SELECT DISTINCT department from worker

--Q4
SELECT SUBSTRING(first_name from 1 for 3) from worker

--Q5 ?? 'amitabh'
SELECT POSITION('a' in first_name)
from worker;

--Q6
SELECT trim(trailing ' ' from first_name) As first_name_without_trails from worker

--Q7
SELECT trim(leading ' ' from department) As department_without_leads from worker

--Q8
SELECT distinct length(department) As length_of_departments from worker 

--Q9
SELECT replace(first_name, 'a','A') from worker 

--Q10
SELECT (first_name || ' ' || last_name) As complete_name from worker

--Q11
SELECT * from worker order by first_name

--Q12
SELECT * from worker order by first_name, department desc

--Q13
SELECT * from worker where first_name = 'Vipul' and last_name = 'Satish'

--Q15
SELECT * from worker where department = 'Admin'

--Q16
SELECT * from worker where first_name like '%a%'

--Q17
SELECT * from worker where first_name like '%a'

--Q18
SELECT * from worker where first_name like '%h' and length(first_name) = 6 

--Q19
SELECT * from worker where salary between 100000 and 500000

--Q20
SELECT * from worker where joining_date between '2014-02-01 00:00:00' and '2014-02-01 23:59:59' 

--Q21
SELECT Count(worker_id) as number_of_workers from worker where department = 'Admin'

--Q22
SELECT (first_name || ' ' || last_name) As full_name from worker where salary between 50000 and 100000

--Q23
SELECT department, Count(worker_id) as number_of_workers from worker group by department order by number_of_workers desc

--Q24
SELECT * from worker w join title t on w.worker_id = t.worker_ref_id where worker_title = 'Manager'

--Q25
With dups as(SELECT first_name, last_name, department, count(*) from worker
group by first_name, last_name, department having count(*) > 1)

SELECT * from dups

--Q26
SELECT * from worker where (worker_id % 2 = 1)

--Q27
SELECT * from worker where (worker_id % 2 = 0)

--Q28
Create Table worker_copy as table worker

SELECT * from worker_copy --testing purposes

--Q29
SELECT * from worker w where exists( select * from worker_copy wc where w.worker_id = wc.worker_id) 

--Q30
SELECT * from worker w where not exists( select * from worker_copy wc where w.worker_id = wc.worker_id) 

--Q31
SELECT current_TIMESTAMP

--Q32
SELECT * from worker limit 10

--Q33 here n = 5
SELECT salary from ( SELECT salary, row_number() over (order by salary desc) as row_num from worker)
 as nth_salary where row_num = 5

--Q34 same query??
SELECT salary from ( SELECT salary, row_number() over (order by salary desc) as row_num from worker)
 as nth_salary where row_num = 5

--Q35
SELECT w1.* from worker w1 join worker w2 on w1.salary = w2.salary and w1.worker_id != w2.worker_id

--Q36
SELECT salary from ( SELECT salary, row_number() over (order by salary desc) as row_num from worker)
 as nth_salary where row_num = 2

--Q37
with no_rows as (SELECT *, row_number() over(order by worker_id) as rn from worker_copy)
Insert into worker_copy (worker_id, first_name, last_name, salary, joining_date, department)
SELECT worker_id, first_name, last_name, salary, joining_date, department from no_rows where rn = 3;

SELECT * from worker_copy --testing purposes

--Q39
SELECT * from worker order by worker_id limit (select(count(*)/2) from worker)

--Q40
SELECT department, count(department) as emp_in_dep from worker group by department having count(department) < 5

--Q41
SELECT department, count(department) as emp_in_dep from worker group by department

--Q42
SELECT * from worker order by joining_date desc limit 1

--Q43
SELECT * from worker limit 1

--Q44
SELECT * from worker order by joining_date desc limit 5

--Q45
SELECT * from worker w join (SELECT department, max(salary) as max_salary from worker wc group by department ) department_max on w.department = department_max.department and w.salary = department_max.max_salary

--Q46
SELECT * from worker order by salary desc limit 3

--Q47
SELECT * from worker order by salary limit 3

--Q48 here nth = 6
SELECT * from ( Select *, row_number() over (order by worker_id) as rn from worker ) as nth_salary where rn = 6

--Q49
SELECT department, sum(salary) as total_salaries from worker group by department 

--Q50
SELECT w.first_name, w.last_name, (w.salary + b.bonus_amount) as total_earnings from worker w join bonus b on w.worker_id = b.worker_ref_id order by total_earnings desc limit 1
