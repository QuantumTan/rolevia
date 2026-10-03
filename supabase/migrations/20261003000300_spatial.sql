begin;
create extension if not exists postgis with schema extensions;
alter table public.jobs add column latitude double precision check(latitude between -90 and 90);
alter table public.jobs add column longitude double precision check(longitude between -180 and 180);
alter table public.jobs add column geom extensions.geography(Point,4326)
  generated always as (extensions.st_setsrid(extensions.st_makepoint(longitude,latitude),4326)::extensions.geography) stored;
create index jobs_proximity on public.jobs using gist(geom);
create function public.nearby_jobs(p_lat double precision,p_lng double precision,p_radius double precision,
  p_distance double precision default -1,p_id uuid default '00000000-0000-0000-0000-000000000000',p_limit integer default 20)
returns table(job jsonb,distance_m double precision) language sql stable security invoker set search_path = '' as $$
  select to_jsonb(j)-'geom',extensions.st_distance(j.geom,extensions.st_setsrid(extensions.st_makepoint(p_lng,p_lat),4326)::extensions.geography) as d
  from public.jobs j
  where p_lat between -90 and 90 and p_lng between -180 and 180 and p_radius between 0.1 and 200
    and extensions.st_dwithin(j.geom,extensions.st_setsrid(extensions.st_makepoint(p_lng,p_lat),4326)::extensions.geography,p_radius*1000)
    and (extensions.st_distance(j.geom,extensions.st_setsrid(extensions.st_makepoint(p_lng,p_lat),4326)::extensions.geography),j.id)>(p_distance,p_id)
  order by d,j.id limit least(greatest(p_limit,1),100);
$$;
revoke all on function public.nearby_jobs(double precision,double precision,double precision,double precision,uuid,integer) from public,anon;
grant execute on function public.nearby_jobs(double precision,double precision,double precision,double precision,uuid,integer) to authenticated;
commit;
