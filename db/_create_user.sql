create user testersam identified by :password default tablespace users quota unlimited on users;

grant create session, create sequence, create procedure, create type, create table, create view, create synonym, create trigger to testersam;

grant alter session to testersam;