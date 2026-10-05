alter table public.applications
  add column resume_id uuid,
  add column interview_at timestamptz,
  add column salary_offered integer check (salary_offered >= 0),
  add constraint applications_resume_owner_fk foreign key (user_id, resume_id)
    references public.resumes(user_id, id);

-- Keep the existing ownership, timestamp and idempotency checks for every entity.
alter function public.apply_mutation(uuid, text, text, jsonb) rename to apply_mutation_core;
revoke all on function public.apply_mutation_core(uuid, text, text, jsonb) from public, anon, authenticated;

create function public.apply_mutation(p_key uuid, p_entity text, p_action text, p_payload jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  response jsonb;
  uid uuid := auth.uid();
  replay boolean;
begin
  if uid is null then raise exception 'Authentication required' using errcode = '42501'; end if;
  perform pg_advisory_xact_lock(hashtextextended(uid::text || p_key::text, 0));
  select exists(select 1 from public.mutation_receipts
    where user_id = uid and idempotency_key = p_key) into replay;
  response := public.apply_mutation_core(p_key, p_entity, p_action, p_payload);
  if replay then return response; end if;
  if p_entity = 'applications' and p_action = 'upsert' then
    update public.applications
      set resume_id = (p_payload->>'resumeId')::uuid,
          interview_at = (p_payload->>'interviewAt')::timestamptz,
          salary_offered = (p_payload->>'salaryOffered')::integer
      where id = (p_payload->>'id')::uuid and user_id = uid
        and client_updated_at <= coalesce((p_payload->>'updatedAt')::timestamptz, clock_timestamp());
    select to_jsonb(a) into response from public.applications a
      where a.id = (p_payload->>'id')::uuid and a.user_id = uid;
    update public.mutation_receipts set result = response
      where user_id = uid and idempotency_key = p_key;
  end if;
  return response;
end;
$$;
revoke all on function public.apply_mutation(uuid, text, text, jsonb) from public, anon;
grant execute on function public.apply_mutation(uuid, text, text, jsonb) to authenticated;
