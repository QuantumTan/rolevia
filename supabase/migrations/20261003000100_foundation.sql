begin;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '' check (char_length(name) <= 120),
  headline text not null default '' check (char_length(headline) <= 240),
  location text not null default '' check (char_length(location) <= 160),
  target_roles text[] not null default '{}' check (cardinality(target_roles) <= 20),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.jobs (
  id uuid primary key default gen_random_uuid(),
  source text not null,
  source_id text not null,
  role text not null,
  company text not null,
  location text not null,
  work_mode text not null check (work_mode in ('remote', 'hybrid', 'onSite')),
  employment_type text not null check (employment_type in ('fullTime', 'contract', 'partTime')),
  overview text not null,
  skills text[] not null default '{}',
  responsibilities text[] not null default '{}',
  qualifications text[] not null default '{}',
  salary_min integer check (salary_min >= 0),
  salary_max integer check (salary_max >= 0),
  salary_currency text not null default 'PHP',
  salary_period text not null default 'month',
  application_url text check (application_url ~ '^https://'),
  published_at timestamptz not null,
  expires_at timestamptz,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (source, source_id),
  check ((salary_min is null and salary_max is null) or
    (salary_min is not null and salary_max is not null and salary_max >= salary_min))
);

create table public.resumes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 160),
  filename text not null check (char_length(filename) between 1 and 255),
  file_type text not null check (file_type in ('pdf', 'docx')),
  ats_status text not null default 'Not analyzed'
    check (ats_status in ('Not analyzed', 'ATS OK', 'Complex layout')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, id)
);

create table public.saved_jobs (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  job_id uuid not null references public.jobs(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, job_id)
);

create table public.applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  job_id uuid references public.jobs(id) on delete set null,
  company text not null check (char_length(company) between 1 and 160),
  role text not null check (char_length(role) between 1 and 160),
  location text not null default '' check (char_length(location) <= 160),
  stage text not null default 'wishlist'
    check (stage in ('wishlist', 'applied', 'interview', 'offer', 'rejected')),
  applied_at timestamptz,
  follow_up_at timestamptz,
  link text not null default '' check (link = '' or link ~ '^https://'),
  notes text[] not null default '{}' check (cardinality(notes) <= 100),
  version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index jobs_feed on public.jobs(published_at desc, id) where active;
create index resumes_owner on public.resumes(user_id);
create index applications_owner on public.applications(user_id, updated_at, id);
create index applications_job on public.applications(job_id);
create index saved_jobs_job on public.saved_jobs(job_id);

create function public.touch_updated_at() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.created_at := old.created_at;
  new.updated_at := clock_timestamp();
  return new;
end;
$$;

create function public.advance_application_version() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.version := old.version + 1;
  return new;
end;
$$;

create trigger profiles_timestamp before update on public.profiles
for each row execute function public.touch_updated_at();
create trigger jobs_timestamp before update on public.jobs
for each row execute function public.touch_updated_at();
create trigger resumes_timestamp before update on public.resumes
for each row execute function public.touch_updated_at();
create trigger applications_timestamp before update on public.applications
for each row execute function public.touch_updated_at();
create trigger applications_version before update on public.applications
for each row execute function public.advance_application_version();

create function public.create_user_profile() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles(id) values (new.id);
  return new;
end;
$$;
create trigger create_user_profile after insert on auth.users
for each row execute function public.create_user_profile();
insert into public.profiles(id) select id from auth.users on conflict (id) do nothing;

alter table public.profiles enable row level security;
alter table public.jobs enable row level security;
alter table public.resumes enable row level security;
alter table public.saved_jobs enable row level security;
alter table public.applications enable row level security;

create policy profiles_read on public.profiles for select to authenticated
using (id = (select auth.uid()));
create policy profiles_update on public.profiles for update to authenticated
using (id = (select auth.uid())) with check (id = (select auth.uid()));
create policy jobs_read on public.jobs for select to authenticated
using (active and (expires_at is null or expires_at > now()));
create policy resumes_owner on public.resumes for all to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy saved_jobs_owner on public.saved_jobs for all to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy applications_owner on public.applications for all to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

revoke all on public.profiles, public.jobs, public.resumes, public.saved_jobs,
  public.applications from anon, authenticated;
grant select on public.profiles, public.jobs to authenticated;
grant update (name, headline, location, target_roles) on public.profiles to authenticated;
grant select, delete on public.resumes, public.saved_jobs, public.applications to authenticated;
grant insert (id, user_id, title, filename, file_type) on public.resumes to authenticated;
grant update (title) on public.resumes to authenticated;
grant insert (user_id, job_id) on public.saved_jobs to authenticated;
grant insert (id, user_id, job_id, company, role, location, stage, applied_at,
  follow_up_at, link, notes) on public.applications to authenticated;
grant update (job_id, company, role, location, stage, applied_at, follow_up_at,
  link, notes) on public.applications to authenticated;
grant all on public.profiles, public.jobs, public.resumes, public.saved_jobs,
  public.applications to service_role;

revoke execute on function public.touch_updated_at(),
  public.advance_application_version(), public.create_user_profile() from public, anon, authenticated;

commit;
