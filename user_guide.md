# User Guide

Esta guía tiene una idea central: después de instalar Antigravity, una persona
debería poder clonar `biblio_skills`, ejecutar un bootstrap y vivir en chat sin
memorizar la arquitectura del repo.

## Camino Feliz

Primera instalación de una máquina:

```text
Instalar Antigravity
Clonar o descargar biblio_skills
Ejecutar setup/bootstrap-machine
Reabrir Antigravity
Trabajar por chat
```

Si ya tienes Git:

```powershell
git clone https://github.com/reipujal/biblio_skills.git
cd biblio_skills
```

Si todavía no tienes Git, descarga el ZIP del repo desde GitHub, descomprímelo y
abre una terminal en esa carpeta. El bootstrap instalará Git y GitHub CLI para el
trabajo posterior.

Windows:

```powershell
pwsh -File setup\bootstrap-machine.ps1
```

WSL/Linux/macOS:

```bash
./setup/bootstrap-machine.sh
```

Qué deja preparado:

- Git y GitHub CLI disponibles.
- GitHub CLI autenticado, o un error claro pidiendo `gh auth login`.
- `uv` disponible como gestor del toolchain Python.
- Python gestionado por `uv`.
- CLIs globales aisladas: `pre-commit`, `detect-secrets`, `ruff`.
- CLIs LLM auxiliares: `codex`, `claude`, `gemini`.
- Poppler disponible para trabajo con PDFs.
- Rules y skills de `biblio_skills` conectadas con Antigravity.
- Workflows instalables por proyecto cuando pases `-Project` / `--project`.

Al terminar, reabre Antigravity y pregunta al agente nativo:

```text
qué skills tienes disponibles?
```

Importante: dentro de Antigravity puede haber varios paneles. Las skills de este
repo se instalan para el agente nativo de Antigravity, no para el panel Claude
Code embebido.

## Qué Ejecutar

| Situación | Comando o acción |
| --- | --- |
| Estreno o reinstalo un PC Windows | `pwsh -File setup\bootstrap-machine.ps1` |
| Estreno o reinstalo un PC WSL/Linux/macOS | `./setup/bootstrap-machine.sh` |
| Quiero instalar también `/cierre` en un repo Windows | `pwsh -File setup\bootstrap-machine.ps1 -Project C:\ruta\a\repo` |
| Quiero instalar también `/cierre` en un repo Unix | `./setup/bootstrap-machine.sh --project /ruta/a/repo` |
| Ya tengo toolchain y solo quiero reconectar rules/skills | `pwsh -File install.ps1` o `./install.sh` |
| Empiezo un proyecto nuevo | En chat: `Voy a empezar un proyecto nuevo. Usa project-bootstrap.` |
| Reviso guardrails de un repo existente | En chat: `Usa project-guardrails-audit.` |
| No sé si hay una skill para algo | En chat: `Busca si ya existe una skill para esto.` |

## Qué Hace Cada Capa

`setup/bootstrap-machine.*` es el botón de primera instalación. Prepara la
máquina y después llama al instalador de la biblioteca.

`install.ps1` / `install.sh` solo conectan `biblio_skills` con Antigravity:
enlazan skills, propagan rules y, si se indica un proyecto, instalan workflows.
Son útiles para refrescar la biblioteca después de cambios, pero no son el
camino principal para una máquina nueva.

`project-bootstrap` configura repos nuevos. No reinstala la máquina: crea la
estructura del proyecto, sus guardrails, su `AGENTS.md`, sus tests iniciales y su
flujo reproducible.

`ci-templates/` son plantillas por proyecto. No se instalan globalmente porque
cada repo tiene comandos, tests y stack propios.

## Crear Un Proyecto Nuevo

Una vez ejecutado el bootstrap global, pide al agente:

```text
Voy a empezar un proyecto nuevo. Usa project-bootstrap.
```

La skill debería encargarse de:

- Crear el `AGENTS.md` del proyecto.
- Crear `README.md`, `.gitignore` y `.env.example`.
- Crear la estructura mínima real del proyecto.
- Preparar dependencias reproducibles si es Python: `requirements.in` y
  `requirements.lock`.
- Copiar/adaptar guardrails de `ci-templates/`.
- Declarar comandos de instalar, probar y ejecutar.
- Instalar `/cierre` en ese proyecto si lo necesitas.
- Hacer commit y push si existe remote.

Si el proyecto ya existe y quieres saber qué checks le faltan, usa
`project-guardrails-audit` en vez de copiar plantillas a mano.

## Trabajo Diario

Normalmente no invocas archivos del repo directamente:

- Las `rules/` están siempre de fondo.
- Las `skills/` se activan cuando tu petición encaja con su descripción.
- Los `workflows/` se invocan explícitamente, por ejemplo `/cierre`.
- Los checks de `ci-templates/` corren por pre-commit o CI en cada repo.

Ejemplos de chat:

```text
Móntame un repo nuevo para analizar PDFs. Usa project-bootstrap.
```

```text
Este repo ha crecido; audita qué guardrails le faltan.
```

```text
Guarda esta decisión en memoria portable.
```

## Catálogo De Skills

El catálogo vive en `INDEX.json` y se genera desde los `SKILL.md`. No se edita a
mano.

Skills principales:

- `audit-board`: auditoría adversarial multi-rol.
- `backend-automation`: scripts backend, scraping, ETL y tareas recurrentes.
- `memory-keeper`: memoria portable en Markdown versionado.
- `multi-agent-collaboration`: coordinación entre modelos/agentes.
- `project-bootstrap`: arranque de repos nuevos.
- `project-guardrails-audit`: revisión de guardrails en repos existentes.
- `skill-development-framework`: diseño o revisión de skills.
- `skill-finder`: búsqueda de skills existentes.

Si cambias o añades una skill:

```bash
python scripts/build_index.py
python scripts/build_index.py --check
```

## Regla Final

Usa esta lógica:

```text
Máquina nueva       -> setup/bootstrap-machine
Refrescar biblioteca -> install.ps1 / install.sh
Proyecto nuevo      -> project-bootstrap
Checks de proyecto  -> project-guardrails-audit + ci-templates
Conocimiento reusable -> skills
Juicio universal    -> rules
```
