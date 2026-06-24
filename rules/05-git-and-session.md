# Git y cierre de sesión

**Al cerrar cualquier sesión con cambios en disco** (código, tests, config, docs):

1. `git status` — identifica qué cambió.
2. Commit agrupado con mensaje descriptivo del conjunto.
3. `git push` para sincronizar con el remote.

Si el proyecto no tiene remote, avísalo: los cambios locales no tienen backup.
La automatización de este cierre vive en el workflow `/cierre`.

**Plan de trabajo por sinergia de ejecución.** Cuando se acumulan varias mejoras o
fixes, agrúpalos por **archivos tocados**, no por criticidad: un bloque = un conjunto
de archivos + un test run + un commit. Una sola pasada de tests por bloque. Las
acciones que modifican estado externo irreversible van en su propio bloque, aisladas
del código. El orden entre bloques lo rigen las dependencias técnicas, salvo que una
corrección bloqueante para una fase prevalezca.

**Protocolo de pausa larga** (semanas/meses): suite limpia, limpieza de artefactos
huérfanos en directorios críticos, verificación de integridad de ficheros de
producción si hay checksums, y un briefing de reanudación (estado actual · qué hacer
primero · qué monitorizar · comandos de diagnóstico).

**Memoria del proyecto — dos capas, sin duplicar:**

1. *Automática y local (Antigravity):* los **Knowledge Items** son el mecanismo nativo.
   Un subagente de conocimiento extrae al cerrar cada conversación los hechos clave y los
   carga al inicio de la siguiente. No requiere mantenimiento manual; **no inventes un
   `memory.md` para esto** — sería redundante. Limitación: son locales a la máquina y a
   Antigravity, no van en git.
2. *Portable y auditable (git):* un único `docs/STATE.md` corto, versionado, que se
   actualiza en `/cierre`: estado actual · siguiente acción · decisiones abiertas. Es lo
   que sobrevive a un cambio de PC, lo que un auditor externo (Gemini/GPT) lee desde
   GitHub, y lo que no depende de Antigravity. Mantenerlo mínimo — no un "memory bank" de
   cinco ficheros (saturación).
