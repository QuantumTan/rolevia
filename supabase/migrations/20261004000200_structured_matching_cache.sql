begin;

create table public.job_parse_cache (
  content_hash text primary key,
  prompt_version text not null,
  model text not null,
  result jsonb not null,
  token_usage jsonb not null default '{}',
  created_at timestamptz not null default now()
);

create table public.resume_profile_cache (
  user_id uuid not null references auth.users(id) on delete cascade,
  content_hash text not null,
  resume_id uuid not null,
  prompt_version text not null,
  model text not null,
  result jsonb not null,
  token_usage jsonb not null default '{}',
  created_at timestamptz not null default now(),
  primary key (user_id, content_hash),
  foreign key (user_id, resume_id)
    references public.resumes(user_id, id) on delete cascade
);

alter table public.job_parse_cache enable row level security;
alter table public.resume_profile_cache enable row level security;

create policy resume_profile_cache_read on public.resume_profile_cache
for select to authenticated
using (user_id = (select auth.uid()));

revoke all on public.job_parse_cache from anon, authenticated;
revoke all on public.resume_profile_cache from anon;
grant select on public.resume_profile_cache to authenticated;

commit;
