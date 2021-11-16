-- Step 1: Identify
select *
from deathstar_users
where lower(name) in (
  select lower(name)
  from deathstar_users
  group by lower(name)
  having count(*) > 1
);

-- Step 2: Correct. See Example 3.1 how to get these updates
update deathstar_users set name = 'Darth Vader', alignment = '„dark“', salary = '15‘000.00', role = 'Sith Lord' where id = 1;
update deathstar_users set name = 'delete', alignment = '', salary = '', role = '' where id = 2;
update deathstar_users set name = 'delete', alignment = '', salary = '', role = '' where id = 3;
update deathstar_users set name = 'Mace Windu', alignment = '„light“', salary = '-', role = 'Prisoner' where id = 4;
update deathstar_users set name = 'Luke Skywalker', alignment = '„bright“', salary = '-300.42', role = 'Pirsoner' where id = 5;
update deathstar_users set name = 'Darth Maul', alignment = '„dark „', salary = '5000', role = 'Sith' where id = 6;
update deathstar_users set name = 'Obi-Wan Kenobi', alignment = '„light“', salary = '0.00', role = 'Prisoner' where id = 7;
delete from deathstar_users where name = 'delete';
commit;

-- Now let's verify we really don't have such problematic data anymore
select * from deathstar_users
where lower(name) in (
  select lower(name)
  from deathstar_users
  group by lower(name)
  having count(*) > 1
);

-- Step 3: Prevent. Add a unique Constraint to the database table
create unique index deathstar_users_uq_name on deathstar_users (lower(name));

-- Now let's check if we really can't add new Darth Vaders
insert into deathstar_users ( id, name ) values (100, 'Darth Vader');
insert into deathstar_users ( id, name ) values (101, 'darTh vader');

-- Step 4: Even doing it a bit better and don't allow leading/trailing whitespaces
drop index deathstar_users_uq_name;
create unique index deathstar_users_uq_name on deathstar_users(lower(trim(name)));

-- Now even whitespaces are dealt with
insert into deathstar_users ( id, name ) values (102, 'Darth Vader   ');