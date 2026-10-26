# STRYBE — Entrena. Progresa. Supérate.

Tracker de entrenamiento PWA para el Entrenamiento 4.0 (bloque de acumulación de 8 semanas).

## Qué hace

- **Entreno guiado**: objetivo de la semana (plan del entrenador) + lo que hiciste la última vez, con las series ya rellenadas.
- **Nunca pierdes un entreno**: se guarda solo mientras entrenas; si el móvil cierra la app, al volver lo recupera.
- **Temporizador de descanso** automático al marcar cada serie (vibración + pitido), pantalla siempre encendida.
- **Récords** (1RM estimado) y pantalla de **Progreso** por ejercicio.
- **Historial** con detalle, filtros y borrado; descanso con "Deshacer".
- **Ejercicios con estado** (v2.1): en cada ejercicio puedes marcar **No lo hice** (con motivo), **Sustituir** por otro (máquina ocupada) o añadir un **ejercicio puntual** solo para ese día, sin tocar la rutina. Los ejercicios nuevos que crees se guardan en tu catálogo con su músculo.
- Los ejercicios sin series marcadas se guardan como *no realizados*: no cuentan como 0 en tu progreso.
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

## Publicar cambios

- La app se actualiza sola: al abrirla carga la versión guardada y descarga la nueva en segundo plano; **la verás al abrirla la siguiente vez**.
- Si cambias `sw.js` o las versiones de React/Babel, sube también `CACHE = 'strybe-vN'` en `sw.js`.
- Las rutinas están en `index.html`, en el bloque `DATOS — ENTRENAMIENTO 4.0`.

## Instalar en el móvil

- **iPhone (Safari):** Abre la URL → botón Compartir → "Añadir a pantalla de inicio"
- **Android (Chrome):** Abre la URL → menú ⋮ → "Añadir a pantalla de inicio"

Los datos se guardan solo en el dispositivo. Exporta una copia de vez en cuando (Ajustes → Exportar).
