# Git y cierre de sesión

**Al cerrar cualquier sesión con cambios en disco** (código, tests, config, docs):

1. `git status` — identifica qué cambió.
2. **Commits atómicos secuenciales** — NUNCA agrupes cambios de naturaleza distinta (ej: refactor de código y actualización de README) en un solo "commit Frankenstein". Haz los `git add` y `git commit` por separado de forma automática y secuencial, **sin pedir intervención al usuario**.
3. `git push` para sincronizar con el remote.

Si el proyecto no tiene remote, avísalo: los cambios locales no tienen backup.
La automatización de este cierre vive en el workflow `/cierre`.

**Plan de trabajo por unidad lógica.** Cuando se acumulan varias mejoras o fixes,
agrúpalos por **unidad lógica** (un cambio coherente, verificable y revertible): un bloque
= una unidad + un test run + un commit. Los archivos tocados son indicador secundario, no
el criterio. Una sola pasada de tests por bloque. Las acciones que modifican estado externo
irreversible van en su propio bloque, aisladas del código. El orden entre bloques lo rigen
las dependencias técnicas, salvo que una corrección bloqueante para una fase prevalezca.

**Protocolo de pausa larga** (semanas/meses): suite limpia, limpieza de artefactos
huérfanos en directorios críticos, verificación de integridad de ficheros de
producción si hay checksums, y un briefing de reanudación (estado actual · qué hacer
primero · qué monitorizar · comandos de diagnóstico).

**Memoria del proyecto — dos capas, sin duplicar:**

1. *Automática y local (Antigravity):* los **Knowledge Items** son el mecanismo nativo.
   Un subagente de conocimiento extrae al cerrar cada conversación los hechos clave y los
   carga al inicio de la siguiente. No requiere mantenimiento manual. Limitación: son
   locales a la máquina y a Antigravity, no van en git, y NO los lee Claude Code.
2. *Portable y auditable (git):* memoria versionada que cualquier harness lee vía `@import`
   y que sobrevive a un cambio de PC. La estructura canónica la define la skill
   **`memory-keeper`** (`docs/memory/`: un índice `MEMORY.md` autogenerado + ficheros
   tipados). El estado de proyecto vive ahí como `docs/memory/project-state.md`, que es lo
   que `/cierre` actualiza. No crees ficheros de memoria ad-hoc fuera de ese sistema
   (saturación); usa memory-keeper, que es la fuente única de la capa portable.
