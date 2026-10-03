begin;
create extension if not exists pgtap with schema extensions;
select plan(6);

insert into auth.users(id) values
  ('11111111-1111-4111-8111-111111111111'),
  ('22222222-2222-4222-8222-222222222222');

set local role authenticated;
select set_config('request.jwt.claim.sub', '11111111-1111-4111-8111-111111111111', true);
select is((select count(*)::integer from public.profiles), 1, 'profile reads are owner scoped');
insert into public.applications(id, company, role) values
  ('44444444-4444-4444-8444-444444444444', 'Test company', 'Developer');
select is((select version::integer from public.applications), 1, 'new application version');
update public.applications set stage = 'interview' where version = 1;
select is((select version::integer from public.applications), 2, 'server increments version');

select set_config('request.jwt.claim.sub', '22222222-2222-4222-8222-222222222222', true);
select is((select count(*)::integer from public.applications), 0, 'other account cannot read applications');
select throws_ok(
  $$insert into public.applications(user_id, company, role)
    values ('11111111-1111-4111-8111-111111111111', 'Test company', 'Developer')$$,
  '42501', null, 'other account cannot insert as owner');

reset role;
set local role anon;
select throws_ok('select * from public.profiles', '42501', null, 'anonymous profile access denied');
reset role;
select * from finish();
rollback;
