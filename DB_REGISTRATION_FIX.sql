-- SRM Lost & Found: registration trigger fix
-- Run this in Supabase Dashboard > SQL Editor > New query.
-- It replaces the student-code generator so it does not depend on pgcrypto's schema.

create or replace function public.make_student_code()
returns text
language plpgsql
volatile
set search_path = public, pg_temp
as $$
declare
  candidate text;
begin
  loop
    candidate := 'STU-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8));
    exit when not exists (
      select 1 from public.profiles where student_code = candidate
    );
  end loop;
  return candidate;
end;
$$;

-- Ensure the signup trigger is present and uses the corrected generator.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  insert into public.profiles (id, full_name, department, register_number, student_code)
  values (
    new.id,
    left(coalesce(nullif(trim(new.raw_user_meta_data->>'full_name'), ''), split_part(coalesce(new.email, 'student'), '@', 1)), 80),
    nullif(trim(new.raw_user_meta_data->>'department'), ''),
    upper(nullif(trim(new.raw_user_meta_data->>'register_number'), '')),
    public.make_student_code()
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

revoke execute on function public.make_student_code() from public, anon, authenticated;
revoke execute on function public.handle_new_user() from public, anon, authenticated;
