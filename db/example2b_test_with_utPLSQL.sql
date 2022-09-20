/*
  In order for this to work you need to install utPLSQL into your database
  You can find detailed installation instructions here:
  http://www.utplsql.org/utPLSQL/latest/userguide/install.html
 */

create or replace package ut_users_darkside as

  -- %suite(Tests for V_USERS_DARKSIDE)

  -- %test(View shows user of the dark side)
  procedure show_user_dark_side;

  /*-- %test(View doesn't show user of the light side)
  procedure dont_show_user_light_side;

  -- %test(View doesn't show neutral user)
  procedure dont_show_neutral_user;
*/
end;
/

create or replace package body ut_users_darkside as

  procedure show_user_dark_side as
    c_actual sys_refcursor;
  begin
    -- Arrange: Have a user of the dark side
    insert into deathstar_users ( id, name, alignment )
      values ( -1, 'Testperson123', 'dark' );

    -- Assert: We have an entry in the view for that user
    open c_actual for
      select * from v_users_darkside where id = -1;
    ut.expect(c_actual).to_have_count(1);
  end;

  procedure dont_show_user_light_side as
    c_actual sys_refcursor;
  begin
    -- Arrange: Have a user of the light side
    insert into deathstar_users ( id, name, alignment )
      values ( -1, 'Testperson123', 'light' );

    -- Assert: We have an entry in the view for that user
    open c_actual for
      select * from v_users_darkside where id = -1;
    ut.expect(c_actual).to_be_empty();
  end;

  procedure dont_show_neutral_user as
    c_actual sys_refcursor;
  begin
    -- Arrange: Have a neutral user
    insert into deathstar_users ( id, name, alignment )
      values ( -1, 'Testperson123', 'neutral' );

    -- Assert: We have an entry in the view for that user
    open c_actual for
      select * from v_users_darkside where id = -1;
    ut.expect(c_actual).to_be_empty();
  end;

end;
/

select * from ut.run();

