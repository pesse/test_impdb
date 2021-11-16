/* Cleanup: This will delete all the elements created by the examples */
declare
  procedure drop_if_exists(i_name varchar2, i_type varchar2) as
    l_exists integer;
  begin
    select count(*) into l_exists from user_objects
      where object_name = i_name
        and object_type = i_type;
    if l_exists > 0 then
      execute immediate 'drop '||i_type||' "'||i_name||'"';
      dbms_output.put_line('Dropped '||i_type||' "'||i_name||'"');
    else
      dbms_output.put_line(i_type||' "'||i_name||'" does not exist');
    end if;
  end;
begin
  drop_if_exists('DEATHSTAR_USERS', 'VIEW');
  drop_if_exists('V_USERS_DARKSIDE', 'VIEW');
  drop_if_exists('T_DEATHSTAR_USERS', 'TABLE');
  drop_if_exists('DEATHSTAR_USERS', 'TABLE');
  drop_if_exists('ALIGNMENTS', 'TABLE');
  drop_if_exists('ROLES', 'TABLE');
end;
/


/* Setup: This will create the necessary data in their form before the first example */
create table deathstar_users (
  id integer primary key,
  name varchar2(4000),
  alignment varchar2(256),
  salary varchar2(100),
  role varchar2(256)
);

insert into deathstar_users ( id, name, alignment, salary, role ) values (1, 'Darth Vader'   , '„dark“'  , '10‘000.00', 'Sith Lord');
insert into deathstar_users ( id, name, alignment, salary, role ) values (2, 'Darth Vader'   , ''        , '10000.00' , 'Boss'     );
insert into deathstar_users ( id, name, alignment, salary, role ) values (3, 'darth VAder'   , '„Dark“'  , '15000.00' , 'Sith Lord');
insert into deathstar_users ( id, name, alignment, salary, role ) values (4, 'Mace Windu'    , '„light“' , '-'        , 'Prisoner' );
insert into deathstar_users ( id, name, alignment, salary, role ) values (5, 'Luke Skywalker', '„bright“', '-300.42'  , 'Pirsoner' );
insert into deathstar_users ( id, name, alignment, salary, role ) values (6, 'Darth Maul'    , '„dark „' , '5000,00'  , 'Sith'     );
insert into deathstar_users ( id, name, alignment, salary, role ) values (7, 'Obi-Wan Kenobi', '„light“' , '0.00'     , 'Prisoner' );

commit;

create or replace view v_users_darkside as
  select
    *
  from deathstar_users
  where lower(regexp_replace(alignment, '[^[:alpha:]]', '')) = 'dark';

