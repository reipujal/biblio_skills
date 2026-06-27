---
name: memory-keeper
maturity: experimental
description: Memoria persistente y portable del proyecto (markdown en git, leída por cualquier harness vía @import). Úsala cuando el usuario diga "guarda en memoria", "recuerda esto", "anota esto" o pida explícitamente persistir algo; cuando el usuario te corrija un comportamiento ("no hagas X") o confirme un enfoque no obvio; o antes de un /compact o cierre de sesión si hay algo aprendido sin guardar. Destila con juicio QUÉ merece recordarse (no vuelca todo). El usuario decide; tú propones y, con su OK, escribes.
---

# Memory Keeper — memoria persistente portable

Memoria del proyecto como ficheros markdown **en git**, dentro de `docs/memory/`. Se lee en
cualquier harness porque el fichero de gobierno la importa con `@docs/memory/MEMORY.md`
(AGENTS.md para Antigravity, CLAUDE.md para Claude Code). Índice + punteros: `MEMORY.md` es
solo índice; el contenido vive en ficheros individuales.

## Cuándo escribir (destilar con juicio, no volcar)

- El usuario lo pide explícitamente ("guarda en memoria"). → escribe.
- El usuario corrige un comportamiento ("no hagas X", "deja de Y"). → tipo `feedback`.
- El usuario confirma un enfoque no obvio sin pushback ("sí, exacto"). → tipo `feedback`.
- Aprendes algo del estado del proyecto NO derivable del código (decisión, por qué, fecha). → `project`.
- Aprendes dónde vive info externa (Linear, Grafana…). → `reference`.
- Quién es el usuario (rol, expertise, estilo). → `user` (preferentemente global, no por repo —
  ver Alcance).

**Manual-first:** salvo petición explícita de guardar, PROPÓN antes de escribir
("esto parece memoria de tipo feedback, ¿la guardo?"). No escribas memoria sin OK.

## Cuándo NO escribir

Rutas/patrones/arquitectura (derivable con grep) · git history · recetas de fix (están en el
commit) · trabajo en progreso de la sesión (efímero) · listas de PRs/activity (stale en días) ·
lo que ya está en CLAUDE.md/AGENTS.md. Si ya existe una memoria que cubre esto, ACTUALÍZALA, no
dupliques.

## Alcance: por-repo vs global

- `project` y `feedback` sobre este proyecto → `docs/memory/` del repo (en git).
- `user` (quién es, estilo) → NO se duplica por repo: va en la personalización del usuario y, si
  se quiere para los harnesses, en el `GEMINI.md` global una vez.

## Formato de un fichero (`docs/memory/<slug>.md`)

```
---
name: <slug-kebab-case-unico>
description: <resumen de una línea, <150 chars>
metadata:
  type: feedback        # user | feedback | project | reference
---

<regla o hecho, liderando con lo accionable>

**Why:** <por qué — obligatorio en feedback y project; permite aplicarlo en edge cases>
**How to apply:** <cómo se aplica — obligatorio en feedback y project>

[[otro-slug]]           # links opcionales a memorias relacionadas
```
`user`/`reference`: texto libre, sin Why/How obligatorio. Fechas relativas → absolutas al escribir.

## Proceso de escritura (atómico, dos pasos)

1. Genera `slug` kebab-case. Si ya existe memoria similar (mira `MEMORY.md`), ACTUALIZA en vez de
   duplicar. Escribe/edita `docs/memory/<slug>.md`.
2. Regenera el índice: `python <skill>/build_memory_index.py <repo>/docs/memory` (no edites
   `MEMORY.md` a mano). El índice se @importa, así que no lo mantienes tú.

## Disciplina de lectura (lo más importante)

`MEMORY.md` llega por `@import` al abrir sesión. Al usar una memoria:
1. Carga solo los ficheros relevantes a la tarea.
2. **Verifica antes de actuar:** una memoria que nombra un fichero/función/flag es una HIPÓTESIS
   de lo que existía al escribirla. Comprueba en el código antes de actuar sobre ella.
3. **Staleness:** si la memoria contradice el estado actual del código, confía en el código y
   actualiza/borra la memoria.

## Acoplamiento (honesto)

Cero auto-inyección. El único requisito es que AGENTS.md y/o CLAUDE.md contengan
`@docs/memory/MEMORY.md`. Verificado: Antigravity y Claude Code resuelven `@import`.

## Nota de capacidad (futuro, NO asumir)

Automatizar el volcado-con-juicio antes de /compact requeriría un hook PreCompact de tipo
`agent`, que hoy NO existe en Claude Code (es un enhancement inactivo: #36749). Por eso el
disparo es manual (el usuario pide "guarda en memoria") o en el cierre. Si algún día se habilita,
se añade un hook sin tocar el resto del sistema.
