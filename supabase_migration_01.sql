-- =====================================================================
-- STRYBE · migración 01 (Fase E: sincronización de la app)
-- Uso: Supabase > SQL Editor > pegar todo > Run.
-- Se puede ejecutar varias veces sin romper nada. No borra ni cambia datos existentes.
--
-- Qué añade y por qué:
--   sessions.kind          'fuerza' | 'descanso'  → los días de descanso van en sessions (sin tabla nueva)
--   sessions.routine_slug  'pecho', 'espalda'...  → id corto de la rutina (para reconstruir icono y rutina)
--   sessions.complement    'Abs' | 'Gemelo'       → complemento elegido ese día
--   sessions.logged_at     hora exacta del registro (session_date solo guarda el día)
--   sessions.started_at    hora de inicio del entreno
--   session_exercises.group_name  grupo al que pertenecía (Pecho, Abdomen...) para reconstruir la sesión
--   cardio.distance_km     la app guarda la distancia opcional del cardio
--   cardio.logged_at       hora exacta del cardio
-- =====================================================================

alter table public.sessions add column if not exists kind text not null default 'fuerza';
alter table public.sessions drop constraint if exists sessions_kind_check;
alter table public.sessions add constraint sessions_kind_check check (kind in ('fuerza', 'descanso'));
alter table public.sessions add column if not exists routine_slug text;
alter table public.sessions add column if not exists complement   text;
alter table public.sessions add column if not exists logged_at    timestamptz;
alter table public.sessions add column if not exists started_at   timestamptz;

alter table public.session_exercises add column if not exists group_name text;

alter table public.cardio add column if not exists distance_km numeric(6,2);
alter table public.cardio drop constraint if exists cardio_distance_km_check;
alter table public.cardio add constraint cardio_distance_km_check check (distance_km is null or distance_km >= 0);
alter table public.cardio add column if not exists logged_at timestamptz;

-- Para que la API vea las columnas nuevas al momento.
notify pgrst, 'reload schema';

-- Comprobación: debe listar las 8 columnas nuevas.
select table_name, column_name, data_type
from information_schema.columns
where table_schema = 'public'
  and (table_name, column_name) in (
    ('sessions','kind'), ('sessions','routine_slug'), ('sessions','complement'), ('sessions','logged_at'), ('sessions','started_at'),
    ('session_exercises','group_name'), ('cardio','distance_km'), ('cardio','logged_at'))
order by table_name, column_name;
