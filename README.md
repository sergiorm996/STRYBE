# STRYBE — Entrena. Progresa. Supérate.

Tracker de entrenamiento PWA para el Entrenamiento 4.0 (bloque de acumulación de 8 semanas).

## Qué hace

- **Entreno guiado**: objetivo de la semana (plan del entrenador) + lo que hiciste la última vez, con las series ya rellenadas.
- **Nunca pierdes un entreno**: se guarda solo mientras entrenas; si el móvil cierra la app, al volver lo recupera.
- **Pantalla siempre encendida** durante el entreno. El temporizador de descanso está oculto (lo controlas con el reloj); para recuperarlo, pon `SHOW_REST_TIMER = true` en `index.html`.
- **Récords** (1RM estimado) y pantalla de **Progreso** por ejercicio.
- **Historial** con detalle, filtros y borrado; descanso con "Deshacer".
- **Ejercicios con estado** (v2.1): en cada ejercicio puedes marcar **No lo hice** (con motivo), **Sustituir** por otro (máquina ocupada) o añadir un **ejercicio puntual** solo para ese día, sin tocar la rutina. Los ejercicios nuevos que crees se guardan en tu catálogo con su músculo.
- Los ejercicios sin series marcadas se guardan como *no realizados*: no cuentan como 0 en tu progreso.
- **Registro más completo (v2.6)**: **RIR real** por serie (opcional) y **calentamientos** (toca el número de la serie → *C*): no cuentan en volumen, series efectivas ni récords. **Notas** por ejercicio y por sesión.
- **Sugerencia de progresión** (progresión doble): si la última vez llegaste al tope del rango en todas las series de trabajo sin ir más al límite de lo previsto, propone subir peso (+1 kg por debajo de 10 kg, +2 kg hasta 40 kg, +2,5 kg a partir de ahí) con un botón para aplicarlo; si no, mantener peso y buscar una repetición más. El plan del entrenador manda.
- **Editar sesiones guardadas** (Historial → sesión → *Editar sesión*): kg, reps, RIR, calentamiento, estado del ejercicio (hecho, puntual, no lo hice con motivo), añadir o quitar series y notas. Los cambios se sincronizan.
- **Historial**: calendario de **constancia** (12 semanas) y **series por músculo** de las últimas 6 semanas.
- **Rutinas por JSON (v2.5)**: las rutinas viven en `routines.json` (no en el código). En Ajustes → *Rutinas* puedes **importar** un JSON (se valida, ves una vista previa y eliges *Reemplazar bloque* o *Añadir rutinas*) y **exportar** el actual. Las rutinas que se quitan se **archivan**, nunca se borran: el historial no cambia.
- **Resúmenes para tu entrenador IA (v2.4)**: en Progreso → *Semanal* o *Mensual* (4 semanas). Adherencia (rutinas, ejercicios hechos, saltados con motivo, puntuales y sustituidos), series `kg x reps @RIR` por ejercicio con e1RM (Epley) y diferencia con la semana anterior, series efectivas por músculo (sin calentamiento), cardio, peso medio de 7 días, medidas y check-in. El mensual añade tendencia por semana, e1RM primera → última semana, ejercicios estancados (3 semanas sin mejorar el e1RM) y evolución de medidas. Botones *Copiar*, *Compartir* (hoja del iPhone) y *Descargar .md*; con ‹ › eliges semanas anteriores. La app hace todos los cálculos.
- **Cuerpo (v2.3)**: peso diario en un toque, medidas (% grasa, % músculo, cintura, pecho, brazo, muslo) con notas, media móvil de 7 días, cambio semanal y gráfica de tendencia. **Check-in semanal** (sueño, energía y estrés de 1 a 5). Una entrada por día y un check-in por semana (empieza el lunes); todo se puede editar y borrar.
- **Nube (v2.2, opcional)**: con sesión iniciada (Ajustes → Cuenta y sincronización) todo se copia en Supabase y se recupera en otro dispositivo. Sin sesión o sin red la app funciona igual.
- **Copia de seguridad**: exportar (compartir en iPhone) e importar `.json`.
- Funciona **offline** después de la primera carga.

## Desplegar en GitHub Pages

1. Crea un repositorio nuevo en GitHub (puede ser privado o público)
2. Sube estos archivos:
   ```
   git init
   git add .
   git commit -m "STRYBE v2"
   git branch -M main
   git remote add origin https://github.com/TU_USUARIO/TU_REPO.git
   git push -u origin main
   ```
3. En GitHub → Settings → Pages → Source: **Deploy from branch `main`**, carpeta `/ (root)`
4. En ~1 minuto la app estará en: `https://TU_USUARIO.github.io/TU_REPO/`

## Publicar cambios y actualizaciones

- Cada vez que cambies algo, sube **las dos** versiones: `CACHE = 'strybe-vN'` en `sw.js` y `window.STRYBE_VERSION` al principio de `index.html`.
- Desde la 2.1.1 la app **se actualiza sola**: al volver a ella busca un `sw.js` nuevo y, si lo hay, recarga. Si estás a mitad de un entreno, espera a que lo guardes o descartes.
- La versión instalada se ve en la pantalla de carga y en **Ajustes → Acerca de** (con el nombre de la caché). Ahí también está **Buscar actualización**.
- Pasar de la 2.1 a la 2.1.1 es el único salto manual: la 2.1 no sabe actualizarse sola, así que hay que cerrar la app del todo y abrirla un par de veces (ver abajo).
- Las rutinas están en `routines.json` (ver *Rutinas* más abajo). Súbelo siempre junto a `index.html` y `sw.js`.

### Si el iPhone sigue mostrando una versión vieja (sin perder datos)

1. Comprueba que GitHub ya sirve lo nuevo: abre `https://sergiorm996.github.io/STRYBE/sw.js` en Safari y mira la línea `const CACHE`.
2. Con wifi o datos, abre STRYBE, espera 5 segundos y **ciérrala del todo** (desliza hacia arriba desde la barra inferior, mantén y desliza la app hacia arriba).
3. Ábrela otra vez, espera 5 segundos y repite el cierre. A la segunda o tercera apertura verás la versión nueva en la pantalla de carga.
4. **No** borres los datos de Safari ni la app de la pantalla de inicio: ahí vive tu historial.

## Rutinas (`routines.json`)

Formato (el plan es `[kg, reps]` por serie y por semana; `reps` puede ser texto, como `"Clúster"`):

```json
{
  "version": 1,
  "bloque": { "nombre": "Entrenamiento 4.0", "semanas": 8 },
  "rutinas": [
    { "id": "pecho", "nombre": "Pecho", "icono": "💥", "color": "coral", "ejercicios": [
      { "ejercicio": "Press Horizontal Technogym", "musculo": "pecho", "series": 4, "reps": "6-8", "rir": 2,
        "nota": "Última serie clúster 4+4+4 (15s pausa)",
        "plan": { "1": [[37.5, 8], [37.5, 8], [40, "Clúster"]], "2": [[42, 8], [42, 8], [42, "Clúster"]] } }
    ] }
  ],
  "complementos": [ { "id": "Abs", "nombre": "Abdomen", "icono": "🔥", "ejercicios": [] } ]
}
```

- **Obligatorio**: `id` (sin espacios), `nombre`, y en cada ejercicio `ejercicio`, `musculo`, `series` y `reps`. Opcional: `icono`, `color` (coral, azul, violeta, ambar, lima, cian), `rir`, `nota` y `plan`.
- **Músculos válidos**: pecho, espalda, hombro, bíceps, tríceps, cuádriceps, femoral, glúteo, gemelo, abdomen, lumbar, antebrazo, otro.
- **Plan**: si una semana no tiene plan se usa la anterior como referencia. Una rutina sin plan (`"plan": {}`) funciona igual: Pierna está así, lista para cuando llegue su plan.
- **Dos formas de cambiarlas**: importar el JSON desde Ajustes (recomendado) o editar `routines.json` y subirlo. Lo segundo solo se aplica solo si estás usando las rutinas por defecto; si importaste unas, mandan esas.
- Si el JSON tiene errores, la app dice exactamente dónde (por ejemplo `rutinas[0] ("Pecho").ejercicios[2].series: debe ser un número entero entre 1 y 20`) y no cambia nada.

## Nube (Supabase)

- **Local primero**: los datos viven en el dispositivo (`localStorage`); la nube es copia y sincronización. Sin sesión no se descarga nada de Supabase.
- **Iniciar sesión**: Ajustes → *Cuenta y sincronización*, con correo y contraseña. La sesión se mantiene sola.
- **Primera vez**: antes de subir nada, la app guarda una copia en el dispositivo (`strybe_backup_presync`) y ofrece descargarla. Luego sube todo el historial (sin duplicar: cada registro tiene un UUID fijo).
- **Dispositivo nuevo**: al iniciar sesión baja todo y rehace el historial.
- **Cola**: cada cambio (nuevo, editado o borrado) queda pendiente en `strybe_sync_v1` y se sube cuando hay red y sesión, por lotes y con reintentos. Se sincroniza al abrir la app, al volver a ella, al recuperar la red y cada 5 minutos.
- **Borrar** en la app pone `deleted_at` en la nube (nunca se borran filas). Conflictos: gana el cambio más reciente.
- **Qué se sube**: entrenos → `sessions` (+ `session_exercises`, `sets`, `cardio`), días de descanso → `sessions` con `kind = 'descanso'`, cardio libre → `cardio` sin `session_id`, ejercicios propios y de las rutinas → `exercises`, rutinas → `blocks`, `routines` (las archivadas con `is_active = false`) y `routine_exercises`, peso y medidas → `body_metrics`, check-ins → `weekly_checkins`. Si el mismo día se registra en dos dispositivos, se fusiona (manda el más reciente y los huecos se rellenan con el otro). De las series solo se suben **las marcadas como hechas**.
- **Indicador** en Inicio: *Sin sesión*, *Sincronizando…*, *Al día · hh:mm*, *N pendientes*, *Sin conexión*, *Nube en pausa* / *Error nube* (con Reintentar en Ajustes).
- **Plan gratuito**: si Supabase pausa el proyecto por inactividad, la app lo avisa y sigue funcionando; reactívalo en supabase.com. La exportación `.json` sigue siendo el seguro.
- **Esquema**: `supabase_schema.sql` (base) + `supabase_migration_01.sql` + `supabase_migration_02.sql` (columnas que usa la app). Pega cada uno en *SQL Editor → Run*; se pueden ejecutar varias veces.

## Instalar en el móvil

- **iPhone (Safari):** Abre la URL → botón Compartir → "Añadir a pantalla de inicio"
- **Android (Chrome):** Abre la URL → menú ⋮ → "Añadir a pantalla de inicio"

Los datos se guardan solo en el dispositivo. Exporta una copia de vez en cuando (Ajustes → Exportar).
