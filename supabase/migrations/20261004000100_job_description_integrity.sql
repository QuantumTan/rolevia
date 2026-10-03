begin;

alter table public.jobs
  add column if not exists original_description text,
  add column if not exists description_truncated boolean not null default false,
  add column if not exists description_source text not null default 'full'
    check (description_source in ('full', 'snippet', 'pasted'));

update public.jobs
set original_description = overview
where original_description is null;

commit;
