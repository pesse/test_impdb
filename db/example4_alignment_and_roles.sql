-- Step 1: Identify
-- What we want to identify is what different entries for Alignments and Roles we actually have in the database
select distinct alignment from deathstar_users;
select distinct role from deathstar_users;

-- We can even do this and add some SQL magic, removing a lot of noise
select distinct
  -- Read the following from the most inner bracket first
  '„' || -- 4th we add the quotation marks back again
  lower( -- 3rd we make everything lowercase
    trim( -- 2nd we trim to remove all unnecessary whitespaces
      regexp_replace(alignment, '[„“]', '') -- 1st we remove those strange quotation marks
    )
  )
  || '“' -- 4th adding the closing quotation mark
    as alignment
from deathstar_users;

-- Step 2: Correct Alignment
-- First, we need to define a new table and insert all the valid entries
create table alignments (
  id integer generated always as identity primary key,
  name varchar2(256) not null unique -- Let's also make sure alignment-name is unique
);

-- Inserting the valid entries in these situations is best done by hand, most of the time
insert into alignments ( name ) values ('„dark“');
insert into alignments ( name ) values ('„light“');
insert into alignments ( name ) values ('„neutral“');

-- Now we need a new column in the deathstar_users table
alter table deathstar_users
  add alignment_id integer;

-- If the existing values are so over the place, we need to do some manual work again.
-- But we can also use SQL to help us
update deathstar_users set
  alignment_id = (select id from alignments where name = '„dark“')
where lower(alignment) like '%dark%';

update deathstar_users set
  alignment_id = (select id from alignments where name = '„light“')
where lower(alignment) like '%light%'
  or  lower(alignment) like '%bright%';

commit;

-- Let's check what we have now
select duser.name     as username
      ,alignment      as original_alignment
      ,align.name     as new_alignment
from deathstar_users duser
  left outer join alignments align
    on duser.alignment_id = align.id
;

-- Looks good, so now we can remove the old column
alter table deathstar_users
  drop column alignment;

-- Bonus: To not break any existing applications (we changed the column name), we can use a view to mimic
-- the old behaviour and rename the underlying table
alter table deathstar_users rename to t_deathstar_users;

create or replace view deathstar_users as
  select duser.id
        ,duser.name
        ,align.name as alignment
        ,duser.salary
        ,duser.role
    from t_deathstar_users duser
      left outer join alignments align
        on duser.alignment_id = align.id
;

select * from deathstar_users;

-- If we want to also allow insert/update/delete into the view, we will have to add an instead-of trigger
-- It's totally possible to do, if you want to know more, send me an e-Mail or hit me up via Twitter DM (@Der_Pesse)

-- Step 3: Prevent by adding a foreign key
alter table t_deathstar_users
  add foreign key ( alignment_id ) references alignments( id );

-- We cannot add an entry with a non-existing Alignment-ID anymore
insert into t_deathstar_users( id, name, alignment_id )
  values ( 300, 'Jar Jar Binks', 10);

-- Steps 2 and 3 for roles
-- When changing things, we should always work in steps as small as possible
-- Fight the urge to change and improve several things at once, you will end up being a lot slower and a lot more stressed!
create table roles (
  id integer generated always as identity primary key,
  name varchar2(256) not null unique
);

insert into roles ( name )
  select distinct role
  from deathstar_users
  where role != 'Pirsoner';

select * from roles;

alter table t_deathstar_users
  add role_id integer references roles( id ) -- we can specify the foreign key right when adding the column
;

update t_deathstar_users set
  role_id = (select id from roles where name = 'Sith')
where role = 'Sith';
update t_deathstar_users set
  role_id = (select id from roles where name = 'Sith Lord')
where role = 'Sith Lord';
update t_deathstar_users set
  role_id = (select id from roles where name = 'Prisoner')
where role in ('Prisoner', 'Pirsoner');

select duser.name     as username
      ,role           as original_role
      ,t_role.name    as new_role
from t_deathstar_users duser
  left outer join roles t_role
    on duser.role_id = t_role.id;

create or replace view deathstar_users as
  select duser.id
        ,duser.name
        ,align.name as alignment
        ,duser.salary
        ,t_role.name as role
    from t_deathstar_users duser
      left outer join alignments align
        on duser.alignment_id = align.id
      left outer join roles t_role
        on duser.role_id = t_role.id
;

alter table t_deathstar_users
  drop column role;

select * from deathstar_users;