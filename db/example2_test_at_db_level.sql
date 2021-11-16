declare
  l_exists integer;
begin
  -- Arrange
  -- A little trick here to not collide with existing entries: use negative primary keys
  insert into deathstar_users ( id, name, alignment )
    values ( -1, 'Testperson123', 'dark' );

  -- Assert: There should be an entry in our view under test
  select count(*) into l_exists
    from v_users_darkside
    where name = 'Testperson123';

  -- Cleanup our testdata
  rollback;

  if l_exists = 0 then
    raise_application_error(-20000, 'Expected Testperson123 to be in view, but wasnt');
  end if;
end;
/