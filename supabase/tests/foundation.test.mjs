import { PGlite } from '@electric-sql/pglite';
import { readFile, readdir } from 'node:fs/promises';
import assert from 'node:assert/strict';
import { before, after, beforeEach, afterEach, test } from 'node:test';

const alice = '11111111-1111-4111-8111-111111111111';
const bob = '22222222-2222-4222-8222-222222222222';
const job = '33333333-3333-4333-8333-333333333333';
const app = '44444444-4444-4444-8444-444444444444';
const resume = '55555555-5555-4555-8555-555555555555';
let db;

before(async () => {
  db = new PGlite();
  // The Supabase runtime supplies these roles and auth objects in deployment.
  await db.exec(`
    create role anon nologin;
    create role authenticated nologin;
    create role service_role nologin bypassrls;
    create schema auth;
    create table auth.users (id uuid primary key);
    create function auth.uid() returns uuid language sql stable as
      $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
    grant usage on schema public, auth to anon, authenticated, service_role;
    grant execute on function auth.uid() to anon, authenticated, service_role;
  `);
  const directory = new URL('../migrations/', import.meta.url);
  for (const file of (await readdir(directory)).filter(f => f.endsWith('.sql')).sort()) {
    await db.exec(await readFile(new URL(file, directory), 'utf8'));
  }
  await db.query('insert into auth.users(id) values ($1), ($2)', [alice, bob]);
  await db.query(`insert into public.jobs
    (id, source, source_id, role, company, location, work_mode, employment_type, overview, published_at)
    values ($1, 'test', 'one', 'Developer', 'Test company', 'Manila', 'remote', 'fullTime', 'Test listing', now())`, [job]);
  await db.query(`insert into public.applications(id, user_id, company, role)
    values ($1, $2, 'Test company', 'Developer')`, [app, alice]);
  await db.query(`insert into public.resumes(id, user_id, title, filename, file_type)
    values ($1, $2, 'Test resume', 'resume.pdf', 'pdf')`, [resume, alice]);
});

beforeEach(() => db.exec('begin'));
afterEach(() => db.exec('rollback'));
after(async () => { await db?.close(); });

async function asUser(id) {
  await db.query("select set_config('request.jwt.claim.sub', $1, true)", [id]);
  await db.exec('set local role authenticated');
}

test('auth inserts create an empty profile; users only see their own profile', async () => {
  await asUser(alice);
  const { rows } = await db.query('select id, name from public.profiles');
  assert.deepEqual(rows, [{ id: alice, name: '' }]);
  assert.equal((await db.query("update public.profiles set name = 'Alice' where id = $1 returning id", [alice])).rows.length, 1);
  assert.equal((await db.query("update public.profiles set name = 'Intruder' where id = $1 returning id", [bob])).rows.length, 0);
});

test('anonymous requests have no table access', async () => {
  await db.exec('set local role anon');
  await assert.rejects(db.query('select * from public.jobs'), { code: '42501' });
});

test('owners create, read, update and delete applications', async () => {
  await asUser(alice);
  const created = await db.query(`insert into public.applications(company, role)
    values ('Another company', 'Engineer') returning id, user_id, version`);
  assert.equal(created.rows[0].user_id, alice);
  assert.equal(Number(created.rows[0].version), 1);
  const updated = await db.query(`update public.applications set stage = 'interview'
    where id = $1 and version = 1 returning version`, [app]);
  assert.equal(Number(updated.rows[0].version), 2);
  const stale = await db.query(`update public.applications set stage = 'offer'
    where id = $1 and version = 1 returning id`, [app]);
  assert.equal(stale.rows.length, 0);
  assert.equal((await db.query('delete from public.applications where id = $1 returning id', [app])).rows.length, 1);
});

test('a second account cannot read, update or delete private records', async () => {
  await asUser(bob);
  for (const table of ['applications', 'resumes', 'saved_jobs']) {
    assert.equal((await db.query(`select * from public.${table}`)).rows.length, 0);
    assert.equal((await db.query(`delete from public.${table} returning *`)).rows.length, 0);
  }
  assert.equal((await db.query("update public.applications set stage = 'offer' returning id")).rows.length, 0);
  assert.equal((await db.query("update public.resumes set title = 'Stolen' returning id")).rows.length, 0);
});

test('clients cannot impersonate another owner when inserting', async () => {
  await asUser(bob);
  await assert.rejects(db.query(`insert into public.applications(user_id, company, role)
    values ($1, 'Test company', 'Developer')`, [alice]), { code: '42501' });
});

test('clients cannot change server-managed versions', async () => {
  await asUser(alice);
  await assert.rejects(db.query('update public.applications set version = 99 where id = $1', [app]), { code: '42501' });
});

test('owners cannot transfer applications to another account', async () => {
  await asUser(alice);
  await assert.rejects(db.query('update public.applications set user_id = $1 where id = $2', [bob, app]), { code: '42501' });
});

test('resume metadata can be created, renamed and deleted by its owner', async () => {
  await asUser(alice);
  const { rows } = await db.query(`insert into public.resumes(title, filename, file_type)
    values ('New resume', 'new.pdf', 'pdf') returning id, ats_status`);
  assert.equal(rows[0].ats_status, 'Not analyzed');
  assert.equal((await db.query("update public.resumes set title = 'Renamed' where id = $1 returning id", [rows[0].id])).rows.length, 1);
  assert.equal((await db.query('delete from public.resumes where id = $1 returning id', [rows[0].id])).rows.length, 1);
});

test('clients cannot insert resume metadata for another account', async () => {
  await asUser(bob);
  await assert.rejects(db.query(`insert into public.resumes(user_id, title, filename, file_type)
    values ($1, 'Forged', 'fake.pdf', 'pdf')`, [alice]), { code: '42501' });
});

test('clients cannot save a job on behalf of another account', async () => {
  await asUser(bob);
  await assert.rejects(db.query('insert into public.saved_jobs(user_id, job_id) values ($1, $2)', [alice, job]), { code: '42501' });
});

test('clients cannot assert an ATS result', async () => {
  await asUser(alice);
  await assert.rejects(db.query("update public.resumes set ats_status = 'ATS OK' where id = $1", [resume]), { code: '42501' });
});

test('invalid application stages are rejected', async () => {
  await asUser(alice);
  await assert.rejects(db.query("update public.applications set stage = 'hired' where id = $1", [app]), { code: '23514' });
});

test('jobs expose only active unexpired listings', async () => {
  await db.query("update public.jobs set expires_at = now() - interval '1 day' where id = $1", [job]);
  await asUser(alice);
  assert.equal((await db.query('select * from public.jobs')).rows.length, 0);
});

test('clients cannot modify the job catalog', async () => {
  await asUser(alice);
  assert.equal((await db.query('select * from public.jobs')).rows.length, 1);
  await assert.rejects(db.query("update public.jobs set company = 'Spoofed'"), { code: '42501' });
});

test('saving a job is unique per account and private', async () => {
  await asUser(alice);
  await db.query('insert into public.saved_jobs(job_id) values ($1)', [job]);
  assert.equal((await db.query('select * from public.saved_jobs')).rows.length, 1);
  await db.exec('reset role');
  await asUser(bob);
  assert.equal((await db.query('select * from public.saved_jobs')).rows.length, 0);
  await db.exec('reset role');
  await asUser(alice);
  await assert.rejects(db.query('insert into public.saved_jobs(job_id) values ($1)', [job]), { code: '23505' });
});

test('account deletion cascades to owned records without deleting jobs', async () => {
  await db.query('insert into public.saved_jobs(user_id, job_id) values ($1, $2)', [alice, job]);
  await db.query('delete from auth.users where id = $1', [alice]);
  for (const table of ['applications', 'resumes', 'saved_jobs']) {
    assert.equal((await db.query(`select * from public.${table} where user_id = $1`, [alice])).rows.length, 0);
  }
  assert.equal((await db.query('select * from public.profiles where id = $1', [alice])).rows.length, 0);
  assert.equal((await db.query('select * from public.jobs')).rows.length, 1);
});
