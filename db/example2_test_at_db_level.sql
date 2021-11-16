declare
  l_exists integer;
begin
  -- Arrange
  -- A little trick here to not collide with existing entries:
  -- use negative primary keys
  insert into deathstar_users ( id, name, alignment )
    values ( -1, 'Testperson123', 'dark' );

  -- Gathering data for assertions later
  select count(*) into l_exists
    from v_users_darkside
    where name = 'Testperson123';

  -- Cleanup our testdata
  rollback;

  -- Assert: There should be exactly one entry here
  if l_exists = 0 then
    raise_application_error(
      -20000,
      'Expected Testperson123 to be in view, but wasnt'
    );
  elsif l_exists > 1 then
    raise_application_error(
      -20000,
      'More than 1 Testperson123 in the view, HALP!'
    );
  end if;
end;
/