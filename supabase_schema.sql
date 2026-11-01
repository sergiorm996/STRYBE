-- =====================================================================
-- STRYBE · esquema Supabase v1
-- Uso: Supabase > SQL Editor > pegar todo > Run
-- Se puede volver a ejecutar sin romper nada (create if not exists / drop if exists).
-- Convenciones:
--   * id = UUID que genera la app (offline primero); user_id = auth.uid() por defecto.
--   * updated_at lo actualiza un trigger; deleted_at = borrado lógico (nunca DELETE desde la app).
--   * Unidades: kg, cm, minutos. Fechas en date; marcas de tiempo en timestamptz.
-- =====================================================================

-- ---------- Función para updated_at ----------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end
$$;

-- ---------- 1. Catálogo de ejercicios ----------
create table if not exists public.exercises (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name               text not null,
  muscle_primary     text not null,
  muscles_secondary  text[] not null default '{}',
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  deleted_at         timestamptz
);
create unique index if not exists exercises_user_name_uq
  on public.exercises (user_id, lower(name)) where deleted_at is null;

-- ---------- 2. Bloques y rutinas (el plan) ----------
create table if not exists public.blocks (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name        text not null,
  weeks       int  not null default 8 check (weeks > 0),
  start_date  date,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

create table if not exists public.routines (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  block_id    uuid references public.blocks(id) on delete set null,
  slug        text not null,                 -- 'pecho', 'espalda'... (id corto del JSON)
  name        text not null,
  position    int  not null default 0,
  is_active   boolean not null default true, -- archivar en vez de borrar
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);
create index if not exists routines_block_idx on public.routines (block_id);

create table if not exists public.routine_exercises (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null default auth.uid() references auth.users(id) on delete cascade,
  routine_id    uuid not null references public.routines(id) on delete cascade,
  exercise_id   uuid not null references public.exercises(id),
  position      int  not null default 0,
  sets_target   int  not null check (sets_target > 0),
  reps_target   text not null,               -- '6-8', '10', etc.
  rir_target    int  check (rir_target between 0 and 10),
  note          text,
  plan          jsonb not null default '{}'::jsonb,  -- {"1": [[42,8],[42,8]], "2": [...]}  = [kg, reps] por semana
  is_active     boolean not null default true,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);
create index if not exists routine_exercises_routine_idx on public.routine_exercises (routine_id);

-- ---------- 3. Entrenos realizados ----------
create table if not exists public.sessions (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null default auth.uid() references auth.users(id) on delete cascade,
  routine_id    uuid references public.routines(id) on delete set null,
  routine_name  text,                         -- copia del nombre en ese momento
  session_date  date not null,
  block_week    int,
  duration_min  int check (duration_min is null or duration_min >= 0),
  notes         text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);
create index if not exists sessions_user_date_idx on public.sessions (user_id, session_date desc);

create table if not exists public.session_exercises (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null default auth.uid() references auth.users(id) on delete cascade,
  session_id     uuid not null references public.sessions(id) on delete cascade,
  exercise_id    uuid references public.exercises(id) on delete set null,
  exercise_name  text not null,               -- copia del nombre en ese momento
  muscle_primary text,                        -- copia del músculo en ese momento
  status         text not null default 'done'
                 check (status in ('done','skipped','extra','substituted')),
  skip_reason    text,                        -- 'maquina_ocupada', 'dolor', 'tiempo', 'cansancio', libre...
  substituted_for text,                       -- nombre del ejercicio original si status='substituted'
  target         jsonb,                       -- objetivo de ese día (copia)
  position       int not null default 0,
  notes          text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  deleted_at     timestamptz
);
create index if not exists session_exercises_session_idx on public.session_exercises (session_id);
create index if not exists session_exercises_exercise_idx on public.session_exercises (exercise_id);

create table if not exists public.sets (
  id                   uuid primary key default gen_random_uuid(),
  user_id              uuid not null default auth.uid() references auth.users(id) on delete cascade,
  session_exercise_id  uuid not null references public.session_exercises(id) on delete cascade,
  set_no               int  not null check (set_no > 0),
  kg                   numeric(6,2) not null default 0 check (kg >= 0),
  reps                 int  not null check (reps >= 0),
  rir_actual           numeric(3,1) check (rir_actual between 0 and 10),
  is_warmup            boolean not null default false,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  deleted_at           timestamptz
);
create index if not exists sets_session_exercise_idx on public.sets (session_exercise_id);

create table if not exists public.cardio (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null default auth.uid() references auth.users(id) on delete cascade,
  session_id   uuid references public.sessions(id) on delete cascade,  -- null = cardio libre
  cardio_date  date not null,
  kind         text not null,
  minutes      numeric(6,1) not null check (minutes > 0),
  notes        text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  deleted_at   timestamptz
);
create index if not exists cardio_user_date_idx on public.cardio (user_id, cardio_date desc);

-- ---------- 4. Seguimiento corporal ----------
create table if not exists public.body_metrics (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null default auth.uid() references auth.users(id) on delete cascade,
  metric_date   date not null,
  weight_kg     numeric(5,2) check (weight_kg is null or weight_kg > 0),
  body_fat_pct  numeric(4,1) check (body_fat_pct is null or body_fat_pct between 0 and 80),
  muscle_pct    numeric(4,1) check (muscle_pct is null or muscle_pct between 0 and 80),
  waist_cm      numeric(5,1),
  chest_cm      numeric(5,1),
  arm_cm        numeric(5,1),
  thigh_cm      numeric(5,1),
  notes         text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);
create unique index if not exists body_metrics_user_date_uq
  on public.body_metrics (user_id, metric_date) where deleted_at is null;

create table if not exists public.weekly_checkins (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  week_start  date not null,                  -- lunes de la semana
  sleep       int check (sleep  between 1 and 5),
  energy      int check (energy between 1 and 5),
  stress      int check (stress between 1 and 5),
  notes       text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);
create unique index if not exists weekly_checkins_user_week_uq
  on public.weekly_checkins (user_id, week_start) where deleted_at is null;

-- ---------- 5. Seguridad (RLS) + trigger + índice de sincronización ----------
-- Cada usuario solo ve y escribe SUS filas. El rol anónimo no puede nada.
do $$
declare
  t text;
begin
  foreach t in array array[
    'exercises','blocks','routines','routine_exercises',
    'sessions','session_exercises','sets','cardio',
    'body_metrics','weekly_checkins'
  ]
  loop
    execute format('alter table public.%I enable row level security', t);

    execute format('drop policy if exists "own rows" on public.%I', t);
    execute format(
      'create policy "own rows" on public.%I for all to authenticated
         using ((select auth.uid()) = user_id)
         with check ((select auth.uid()) = user_id)', t);

    execute format('drop trigger if exists set_updated_at on public.%I', t);
    execute format(
      'create trigger set_updated_at before update on public.%I
         for each row execute function public.set_updated_at()', t);

    execute format(
      'create index if not exists %I on public.%I (user_id, updated_at)',
      t || '_sync_idx', t);
  end loop;
end
$$;

-- ---------- 6. Comprobación (debe mostrar rowsecurity = true en las 10 tablas) ----------
select tablename, rowsecurity
from pg_tables
where schemaname = 'public'
order by tablename;
