-- =====================================================================
-- STRYBE · migración 02 (Fase D: rutinas por JSON)
-- Uso: Supabase > SQL Editor > pegar todo > Run. Antes debe estar aplicada la 01.
-- Se puede ejecutar varias veces sin romper nada. No borra ni cambia datos existentes.
--
-- Qué añade:
--   routines.kind   'rutina' | 'complemento'   (los complementos —Abdomen, Gemelo— también son "rutinas")
--   routines.icon   emoji de la rutina
--   routines.color  color de la tarjeta (coral, azul, violeta, ambar, lima, cian)
-- Las rutinas quitadas al importar un JSON quedan con is_active = false (nunca se borran).
-- =====================================================================

alter table public.routines add column if not exists kind  text not null default 'rutina';
alter table public.routines drop constraint if exists routines_kind_check;
alter table public.routines add constraint routines_kind_check check (kind in ('rutina', 'complemento'));
alter table public.routines add column if not exists icon  text;
alter table public.routines add column if not exists color text;

notify pgrst, 'reload schema';

-- Comprobación: debe listar las 3 columnas nuevas.
select column_name, data_type
from information_schema.columns
where table_schema = 'public' and table_name = 'routines' and column_name in ('kind', 'icon', 'color')
order by column_name;
