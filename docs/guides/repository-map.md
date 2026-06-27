# Mapa De Uso Del Repositorio

Esta guía explica qué es cada pieza de `biblio_skills` y cuándo usarla. No es una
descripción abstracta: es un mapa práctico para trabajar con Antigravity y otros
agentes LLM.

## Idea General

`biblio_skills` es la biblioteca central de prácticas reutilizables para agentes.
No es un almacén de prompts. Su trabajo es evitar que cada proyecto copie,
reinvente o degrade las mismas reglas.

La lógica es:

```text
Máquina nueva          -> setup/bootstrap-machine
Refrescar biblioteca   -> install.ps1 / install.sh
Proyecto nuevo         -> project-bootstrap
Cierre de sesión       -> /cierre
Checks automáticos     -> ci-templates
Juicio universal       -> rules
Capacidades reutilizables -> skills
```

## `setup/bootstrap-machine.ps1` Y `setup/bootstrap-machine.sh`

Son el botón de primera instalación de una máquina.

Úsalos cuando:

- estrenas un PC;
- reinstalas Windows/Linux/macOS;
- quieres reconstruir el entorno global de trabajo;
- ya instalaste Antigravity y descargaste `biblio_skills`.

Preparan:

- Git y GitHub CLI;
- `uv`;
- Node.js/npm;
- Python gestionado por `uv`;
- `pre-commit`, `detect-secrets`, `ruff`;
- `codex`, `claude`, `gemini`;
- Poppler;
- conexión de `biblio_skills` con Antigravity.

No crean proyectos nuevos. Para eso se usa `project-bootstrap`.

## `install.ps1` E `install.sh`

Son instaladores de la biblioteca, no de toda la máquina.

`install.ps1` es para Windows. `install.sh` es para Unix/WSL/macOS.

Úsalos cuando:

- ya ejecutaste el bootstrap una vez;
- cambiaste rules o skills en `biblio_skills`;
- quieres refrescar lo que Antigravity ve;
- quieres instalar workflows en un proyecto concreto.

Qué hacen:

- Enlazan `skills/` a la carpeta global de skills de Antigravity.
- Escriben un bloque gestionado de rules.
- Instalan workflows por proyecto si reciben una ruta.

Windows:

```powershell
pwsh -File install.ps1
```

Simulación:

```powershell
pwsh -File install.ps1 -DryRun
```

Instalar workflows en un proyecto:

```powershell
pwsh -File install.ps1 -Project C:\ruta\a\repo
```

## `/cierre`

`/cierre` es un workflow, no una skill.

Sirve para cerrar una sesión de trabajo con orden:

- comprobar cambios;
- ejecutar tests si aplica;
- revisar secretos;
- actualizar memoria portable si aplica;
- hacer commit por unidad lógica;
- hacer push;
- dejar un resumen de reanudación.

Importante: Antigravity no carga workflows globales. Por eso `/cierre` se instala
por proyecto en:

```text
<repo>\.agents\workflows
```

Si `/cierre` no aparece al escribir `/`, probablemente no está instalado en ese
proyecto o estás usando el panel equivocado.

## `rules/`

Las rules son criterios universales siempre activos.

Ejemplos:

- no hardcodear secretos;
- tests junto al cambio;
- cambios quirúrgicos;
- dependencias reproducibles;
- cierre con git;
- distinguir hechos de hipótesis;
- buscar skills antes de improvisar;
- diseño mínimo;
- scripts idempotentes y ruidosos al fallar.

Las rules no sustituyen a tests ni linters. Lo determinista debe vivir en CI,
hooks o scripts.

## `skills/`

Las skills son procedimientos reutilizables que el agente carga bajo demanda
cuando la petición encaja con su descripción.

Skills destacadas:

- `project-bootstrap`: crear un repo nuevo con estructura, gobierno y guardrails.
- `project-guardrails-audit`: revisar qué checks automáticos necesita un repo existente.
- `memory-keeper`: guardar memoria portable en Markdown versionado.
- `skill-finder`: buscar si ya existe una skill para una tarea.
- `skill-development-framework`: diseñar o revisar skills.
- `multi-agent-collaboration`: coordinar varios modelos/agentes.
- `audit-board`: auditoría adversarial multi-rol.
- `backend-automation`: scripts backend, scraping, ETL y tareas recurrentes.

No crees una skill nueva solo porque algo suene útil. Debe ser una práctica
reutilizable y validada.

## `workflows/`

Los workflows son comandos explícitos con `/nombre`.

Hoy el principal es:

```text
/cierre
```

Un workflow se invoca manualmente. No se activa por descripción como una skill.

## Memoria Portable Y `/compact`

`memory-keeper` sirve para guardar hechos importantes del proyecto en Markdown
versionado, normalmente bajo `docs/memory/`. Es memoria portable: va en git, la
puede leer cualquier harness y sobrevive a cambiar de ordenador o de modelo.

Úsala cuando:

- tomas una decisión que afectará sesiones futuras;
- corriges una suposición del agente;
- descubres una convención local no obvia;
- cierras una investigación y quieres conservar la conclusión;
- vas a compactar o reiniciar una conversación larga.

Esto es distinto de dejarlo perdido en el chat. El chat puede compactarse,
cortarse o no estar disponible para otro agente; la memoria portable queda en el
repo.

Después de guardar lo importante en memoria, conviene compactar la conversación
si el harness lo permite. En Claude Code, por ejemplo, usa:

```text
/compact
```

En otros LLM o IDEs, usa el mecanismo equivalente: resumir, compactar, reiniciar
la conversación o abrir una nueva. La lógica es:

```text
guardar lo importante en memoria -> compactar/reiniciar chat -> seguir trabajando con menos tokens
```

Esto ahorra contexto y reduce coste/latencia sin perder decisiones importantes.
Primero guarda; luego compacta. Si compactas antes de persistir, puedes perder
matices útiles o decisiones que aún no estaban en ningún archivo.

## `ci-templates/`

Son plantillas de guardrails automáticos para proyectos.

Incluyen:

- baseline de pre-commit;
- detección de secretos;
- check de encoding;
- plantilla de GitHub Actions;
- validador de imports.

No se instalan globalmente porque cada proyecto tiene comandos, tests y stack
propios. `project-bootstrap` los usa al crear repos nuevos y
`project-guardrails-audit` decide qué aplica en repos existentes.

## `INDEX.json`

Es el catálogo generado de skills. No se edita a mano.

Si cambias una skill, ejecuta:

```bash
python scripts/build_index.py
python scripts/build_index.py --check
```

## `docs/ANTIGRAVITY.md`

Explica la mecánica verificada de Antigravity:

- qué carpetas lee;
- diferencia entre agente nativo y panel Claude Code;
- dónde viven skills, rules y workflows;
- por qué workflows no son globales;
- por qué Windows usa junctions.

Léelo cuando algo “no aparece” en Antigravity.

## Situaciones Comunes

### Quiero Empezar Un Proyecto Nuevo

Pide en chat:

```text
Voy a empezar un proyecto nuevo. Usa project-bootstrap.
```

### Quiero Revisar Un Repo Existente

Pide en chat:

```text
Usa project-guardrails-audit y dime qué checks faltan.
```

### Quiero Guardar Una Decisión

Pide en chat:

```text
Guarda esta decisión en memoria portable.
```

Después de que el agente la guarde y la deje en git, si la conversación está
larga, en Claude Code puedes pedir:

```text
/compact
```

O en cualquier otro LLM:

```text
Compacta o resume la conversación usando la memoria portable como fuente.
```

### Cambié Rules O Skills En `biblio_skills`

Ejecuta:

```powershell
pwsh -File install.ps1
```

Luego reabre Antigravity.

### No Sé Si Ya Existe Una Skill

Pide en chat:

```text
Busca si ya existe una skill para esto.
```

El agente debería usar `skill-finder` o revisar `INDEX.json`.
