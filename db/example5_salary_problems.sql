-- Step 1: Identify
-- We want to find all the rows that have salaries with non-numbers
-- First, we should make very sure what number format we are expecting/allowing.
-- Caution: This is very Oracle-specific and might work completely different in your database.
-- In our case, we expect decimal-delimiter to be .
alter session set nls_numeric_characters ='. ';

-- Test our configuration
select to_number('1000.1') from dual;

-- We can either achieve that by regular expression...
select *
from deathstar_users
where not regexp_like(salary, '^\-?[0-9]+\.?[0-9]*$');

-- Or we can use a PL/SQL function (again, this very Oracle specific, other databases might not provide that functionality)
with
  function is_number( i_number varchar2 ) return integer
  as
    l_number number;
  begin
    l_number := to_number(i_number);
    return 1;
  exception when others then
    return 0;
  end;
select *
from deathstar_users
where is_number(salary) = 0
;

-- Step 2: Correct, part 1
-- Again, we should manually correct the problems here or at least very carefully watch whatever changes we are
-- making. Especially with the different separators, it is very risky to use a fully automated, unsupervised approach
-- you might end up with thousands where you excepted fractions
update deathstar_users set
  salary = '15000.00'
where salary = '15‘000.00';
update deathstar_users set
  salary = null
where salary = '-';
commit;

-- Step 3: Prevent, part 1
-- Now that we have valid numbers, we can set our salary to be an actual number field
-- Because we cannot change the type of a column that contains values, we need to do this transformation in a
-- couple of small steps:

-- First: Add a new column of number
alter table t_deathstar_users
  add salary_new number(38,2);

-- Second: Write the values of salary as number into the new column
update t_deathstar_users set
  salary_new = to_number(salary);

-- Third: Remove salary column
alter table t_deathstar_users
  drop column salary;

-- Fourth: Rename the new column
alter table t_deathstar_users
  rename column salary_new to salary;

select name, salary from t_deathstar_users;

-- Step 2: Correct, part 2
-- Now we can correct the negative salaries - it's so much easier to do this when we have actual numbers
update t_deathstar_users set
  salary = 0
where salary < 0;
commit;

-- Step 3: Prevent, part 3
-- Now we can finally add a check constraint on our new number-column
alter table t_deathstar_users
  add check ( salary >= 0 );

select name, salary from deathstar_users;


-- It's not possible anymore to add negative salaries or salaries that are not valid numbers
insert into t_deathstar_users (id, name, salary) values ( 500, 'Leia Organa', -1000);
insert into t_deathstar_users (id, name, salary) values ( 501, 'Chewbacca', 'no money');
