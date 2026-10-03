begin;
alter table public.profiles add column email text;
alter table public.profiles add constraint profiles_email_unique unique(email);
create unique index idx_profiles_unique_email on public.profiles(lower(btrim(email))) where email is not null;
alter table public.profiles add column scan_quota integer not null default 3 check(scan_quota >= 0);
alter table public.resumes add column deleted_at timestamptz;
alter table public.resumes add column client_updated_at timestamptz not null default now();
alter table public.applications add column deleted_at timestamptz;
alter table public.applications add column client_updated_at timestamptz not null default now();
alter table public.applications add column match_badge text;

create or replace function public.create_user_profile() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles(id,email) values(new.id,nullif(lower(btrim(new.email)),''));
  return new;
end; $$;
create function public.sync_auth_email() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  update public.profiles set email=nullif(lower(btrim(new.email)),'') where id=new.id;
  return new;
end; $$;
create trigger sync_auth_email after update of email on auth.users
for each row execute function public.sync_auth_email();
update public.profiles p set email=nullif(lower(btrim(u.email)),'') from auth.users u where u.id=p.id;

create table public.mutation_receipts (
  user_id uuid not null references auth.users(id) on delete cascade,
  idempotency_key uuid not null, request jsonb not null, result jsonb not null,
  created_at timestamptz not null default now(), primary key(user_id,idempotency_key)
);
alter table public.mutation_receipts enable row level security;

create function public.apply_mutation(p_key uuid,p_entity text,p_action text,p_payload jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid(); rid uuid := (p_payload->>'id')::uuid;
  stamp timestamptz := least(coalesce((p_payload->>'updatedAt')::timestamptz,clock_timestamp()),clock_timestamp());
  receipt public.mutation_receipts; response jsonb; req jsonb;
begin
  if uid is null then raise exception 'Authentication required' using errcode='42501'; end if;
  if p_action not in ('upsert','delete') or p_entity not in ('applications','resumes','saved_jobs','profiles') then
    raise exception 'Unsupported mutation' using errcode='22023';
  end if;
  req := jsonb_build_object('entity',p_entity,'action',p_action,'payload',p_payload);
  perform pg_advisory_xact_lock(hashtextextended(uid::text || p_key::text,0));
  select * into receipt from public.mutation_receipts where user_id=uid and idempotency_key=p_key;
  if found then
    if receipt.request <> req then raise exception 'Idempotency key reused with different request'; end if;
    return receipt.result;
  end if;
  if p_entity='applications' then
    perform pg_advisory_xact_lock(hashtextextended('applications' || rid::text,0));
    if exists(select 1 from public.applications where id=rid and user_id<>uid) then raise exception 'Forbidden' using errcode='42501'; end if;
    if p_action='delete' then
      update public.applications set deleted_at=stamp, client_updated_at=stamp
        where id=rid and user_id=uid and client_updated_at<=stamp;
    else
      insert into public.applications(id,user_id,job_id,company,role,location,stage,applied_at,follow_up_at,link,notes,match_badge,client_updated_at)
      values(rid,uid,(p_payload->>'jobId')::uuid,p_payload->>'company',p_payload->>'role',coalesce(p_payload->>'location',''),
        p_payload->>'stage',(p_payload->>'appliedAt')::timestamptz,(p_payload->>'followUpAt')::timestamptz,
        coalesce(p_payload->>'link',''),array(select jsonb_array_elements_text(coalesce(p_payload->'notes','[]'))),p_payload->>'matchBadge',stamp)
      on conflict(id) do update set job_id=excluded.job_id,company=excluded.company,role=excluded.role,
        location=excluded.location,stage=excluded.stage,applied_at=excluded.applied_at,follow_up_at=excluded.follow_up_at,
        link=excluded.link,notes=excluded.notes,match_badge=excluded.match_badge,client_updated_at=excluded.client_updated_at,deleted_at=null
      where public.applications.user_id=uid and public.applications.client_updated_at<=stamp;
    end if;
    select to_jsonb(a) into response from public.applications a where id=rid and user_id=uid;
  elsif p_entity='resumes' then
    perform pg_advisory_xact_lock(hashtextextended('resumes' || rid::text,0));
    if exists(select 1 from public.resumes where id=rid and user_id<>uid) then raise exception 'Forbidden' using errcode='42501'; end if;
    if p_action='delete' then
      update public.resumes set deleted_at=stamp,client_updated_at=stamp where id=rid and user_id=uid and client_updated_at<=stamp;
    else
      insert into public.resumes(id,user_id,title,filename,file_type,client_updated_at)
      values(rid,uid,p_payload->>'title',p_payload->>'filename',lower(p_payload->>'fileType'),stamp)
      on conflict(id) do update set title=excluded.title,client_updated_at=stamp,deleted_at=null
      where public.resumes.user_id=uid and public.resumes.client_updated_at<=stamp;
    end if;
    select to_jsonb(r) into response from public.resumes r where id=rid and user_id=uid;
  elsif p_entity='saved_jobs' then
    if p_action='delete' then delete from public.saved_jobs where user_id=uid and job_id=rid;
    else insert into public.saved_jobs(user_id,job_id) values(uid,rid) on conflict do nothing; end if;
    response := jsonb_build_object('id',rid);
  elsif p_entity='profiles' then
    update public.profiles set name=coalesce(p_payload->>'name',''),headline=coalesce(p_payload->>'headline',''),
      location=coalesce(p_payload->>'location',''),target_roles=array(select jsonb_array_elements_text(coalesce(p_payload->'targetRoles','[]')))
      where id=uid;
    select to_jsonb(p) into response from public.profiles p where id=uid;
  end if;
  response := coalesce(response,'{}');
  insert into public.mutation_receipts(user_id,idempotency_key,request,result) values(uid,p_key,req,response);
  return response;
end; $$;

create table public.analysis_cache (
  user_id uuid not null references auth.users(id) on delete cascade, cache_key text not null,
  result jsonb not null, created_at timestamptz not null default now(), primary key(user_id,cache_key)
);
create table public.matches (
  id uuid primary key, user_id uuid not null references auth.users(id) on delete cascade,
  resume_id uuid not null, result jsonb not null, request_key uuid not null,
  created_at timestamptz not null default now(), unique(user_id,request_key),
  foreign key(user_id,resume_id) references public.resumes(user_id,id) on delete cascade
);
create table public.ad_nonces (
  nonce uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(), used_at timestamptz
);
create table public.ad_rewards (
  transaction_id text primary key, user_id uuid not null references auth.users(id) on delete cascade,
  nonce uuid not null unique references public.ad_nonces(nonce), created_at timestamptz not null default now()
);
alter table public.analysis_cache enable row level security;
alter table public.matches enable row level security;
alter table public.ad_nonces enable row level security;
alter table public.ad_rewards enable row level security;
create policy matches_read on public.matches for select to authenticated using(user_id=(select auth.uid()));
create policy ad_rewards_read on public.ad_rewards for select to authenticated using(user_id=(select auth.uid()));
grant select on public.matches,public.ad_rewards to authenticated;

create function public.create_ad_nonce() returns uuid
language plpgsql security definer set search_path = '' as $$
declare n uuid;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if (select count(*) from public.ad_nonces where user_id=auth.uid() and created_at>now()-interval '1 hour')>=20 then
    raise exception 'Reward request limit reached';
  end if;
  insert into public.ad_nonces(user_id) values(auth.uid()) returning nonce into n;
  return n;
end; $$;

create function public.credit_ad_reward(p_user uuid,p_nonce uuid,p_transaction text) returns boolean
language plpgsql security definer set search_path = '' as $$
begin
  perform 1 from public.profiles where id=p_user for update;
  if exists(select 1 from public.ad_rewards where transaction_id=p_transaction) then return false; end if;
  update public.ad_nonces set used_at=now() where nonce=p_nonce and user_id=p_user and used_at is null
    and created_at>now()-interval '1 hour';
  if not found then raise exception 'Invalid reward nonce'; end if;
  insert into public.ad_rewards(transaction_id,user_id,nonce) values(p_transaction,p_user,p_nonce);
  update public.profiles set scan_quota=scan_quota+1 where id=p_user;
  return true;
end; $$;

create function public.complete_analysis(p_user uuid,p_request uuid,p_resume uuid,p_hash text,p_result jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare previous jsonb; output jsonb; mid uuid := gen_random_uuid();
begin
  perform 1 from public.profiles where id=p_user for update;
  select result into previous from public.matches where user_id=p_user and request_key=p_request;
  if found then return previous; end if;
  if not exists(select 1 from public.resumes where id=p_resume and user_id=p_user and deleted_at is null) then raise exception 'Resume not found'; end if;
  update public.profiles set scan_quota=scan_quota-1 where id=p_user and scan_quota>0;
  if not found then raise exception 'Scan quota exhausted'; end if;
  output := p_result || jsonb_build_object('id',mid,'resumeId',p_resume,'createdAt',now());
  insert into public.matches(id,user_id,resume_id,result,request_key) values(mid,p_user,p_resume,output,p_request);
  insert into public.analysis_cache(user_id,cache_key,result) values(p_user,p_hash,p_result)
    on conflict(user_id,cache_key) do update set result=excluded.result,created_at=now();
  return output;
end; $$;

grant all on public.mutation_receipts,public.analysis_cache,public.matches,public.ad_nonces,public.ad_rewards to service_role;
revoke all on function public.apply_mutation(uuid,text,text,jsonb),public.create_ad_nonce(),
  public.credit_ad_reward(uuid,uuid,text),public.complete_analysis(uuid,uuid,uuid,text,jsonb),public.sync_auth_email()
  from public,anon,authenticated;
grant execute on function public.apply_mutation(uuid,text,text,jsonb),public.create_ad_nonce() to authenticated;
grant execute on function public.credit_ad_reward(uuid,uuid,text),public.complete_analysis(uuid,uuid,uuid,text,jsonb) to service_role;
commit;
