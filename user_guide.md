# User Guide

Esta guía explica qué usar en `biblio_skills` según la situación. La idea es
simple: no tienes que recordar todos los ficheros; tienes que saber qué puerta
abrir.

## Mapa Mental

`biblio_skills` tiene varios tipos de piezas:

| Pieza | Qué es | Cuándo se usa |
| --- | --- | --- |
| `setup/` | Preparación global de tu máquina | Cuando estrenas o reinstalas un PC |
| `install.ps1` / `install.sh` | Conexión entre `biblio_skills` y Antigravity | Cuando quieres que Antigravity vea las reglas y skills |
| `rules/` | Reglas universales para agentes | Siempre, en cualquier proyecto |
| `skills/` | Capacidades que el agente carga bajo demanda | Cuando la petición encaja con una skill |
| `workflows/` | Comandos manuales tipo `/cierre` | Cuando los instalas en un proyecto y los invocas |
| `ci-templates/` | Plantillas de checks automáticos | Cuando creas/configuras un proyecto concreto |

Piensa así:

```text
Nuevo PC        -> setup/
Conectar IA     -> install.ps1 / install.sh
Nuevo proyecto  -> project-bootstrap
Checks duros    -> ci-templates/
Trabajo diario  -> rules + skills + workflows
```

## Si Vas A Un Nuevo PC

Objetivo: dejar la máquina preparada para trabajar con proyectos asistidos por IA.

1. Clona este repositorio:

   ```bash
   git clone https://github.com/reipujal/biblio_skills.git
   cd biblio_skills
   ```

2. Prepara el toolchain global:

   ```bash
   ./setup/bootstrap-machine.sh
   ```

   Esto prepara cosas de máquina, no de proyecto: Python gestionado por `uv`,
   herramientas globales como `pre-commit`, `detect-secrets`, `ruff`, y comprueba
   herramientas externas como `poppler-utils`.

3. Conecta `biblio_skills` con Antigravity.

   En Windows:

   ```powershell
   pwsh -File install.ps1 -DryRun
   pwsh -File install.ps1
   ```

   En WSL/Linux:

   ```bash
   ./install.sh --dry-run
   ./install.sh
   ```

4. Reinicia Antigravity y verifica que el agente nativo ve las skills.

   Importante: dentro de Antigravity puede haber varios paneles. Las skills de este
   repo están pensadas para el agente nativo de Antigravity, no para el panel de
   Claude Code.

Resultado esperado:

```text
Tu PC tiene herramientas globales.
Antigravity ve las rules.
Antigravity ve las skills.
biblio_skills sigue siendo la fuente de verdad.
```

## Si Quieres Crear Un Proyecto Nuevo En Este PC

Objetivo: arrancar un repo nuevo con estructura, gobierno y barreras desde el
primer commit.

Usa la skill:

```text
project-bootstrap
```

Puedes pedírselo al agente así:

```text
Voy a empezar un proyecto nuevo. Usa project-bootstrap.
```

O así:

```text
Móntame un repo nuevo para <objetivo> con AGENTS.md, tests, CI y pre-commit.
```

La skill debería encargarse de:

- Crear `AGENTS.md` del proyecto.
- Crear `README.md`.
- Crear `.gitignore`.
- Crear `.env.example`.
- Crear estructura mínima (`src/`, `tests/`, etc. si aplica).
- Preparar dependencias reproducibles si es Python (`requirements.in` y lock).
- Copiar las plantillas necesarias de `ci-templates/`.
- Declarar comandos de instalar, probar y ejecutar.
- Instalar el workflow `/cierre` en ese proyecto si lo necesitas.
- Hacer un primer commit y push si hay remote.

Lo importante: `project-bootstrap` configura el proyecto. No debería reinstalar
todo el PC salvo que detecte que falta algo global y te lo diga.

## Si Quieres Que Antigravity Vea Las Skills Y Rules

Usa el instalador del repo:

```text
install.ps1    -> Windows
install.sh     -> WSL/Linux
```

Qué hace:

- Enlaza `skills/<x>/` hacia la carpeta global de skills de Antigravity.
- Escribe un bloque gestionado de reglas en `~/.gemini/GEMINI.md`.
- Opcionalmente instala workflows en un proyecto concreto.

Ejemplo Windows para instalar también `/cierre` en un proyecto:

```powershell
pwsh -File install.ps1 -Project C:\ruta\a\mi-proyecto
```

Ejemplo WSL/Linux:

```bash
./install.sh --project /ruta/a/mi-proyecto
```

Los workflows no son globales en Antigravity: hay que instalarlos por proyecto.

## Si Quieres Usar `ci-templates/`

Objetivo: poner barreras automáticas en un proyecto concreto.

`ci-templates/` es un catálogo de guardrails, **no un repositorio de "copia y pega todo"**. No se instala globalmente y no se debe volcar entero a ciegas.

- Si el repo es nuevo: usa `project-bootstrap` (él instalará el baseline adecuado).
- Si el repo ya existe: usa la skill `project-guardrails-audit`. Ella analizará el proyecto contra las condiciones del catálogo y te propondrá **qué aplica, qué falta y si hay algún hueco de riesgo**, sin romper lo que ya tienes.

Desde la raíz del proyecto destino, si necesitas instalar manualmente los guardrails disponibles (que apliquen):

```bash
cp <biblio_skills>/ci-templates/pre-commit-config.yaml .pre-commit-config.yaml
mkdir -p .github/workflows scripts
cp <biblio_skills>/ci-templates/github-actions-ci.yml .github/workflows/ci.yml
cp <biblio_skills>/ci-templates/check_encoding.py scripts/check_encoding.py

# Si ya ejecutaste setup/bootstrap-machine.sh, estas CLIs ya están instaladas.
uv tool install pre-commit
uv tool install detect-secrets
pre-commit install
detect-secrets scan > .secrets.baseline
```

Después ajusta `.github/workflows/ci.yml` al comando real de tests de ese proyecto.

Qué significa cada pieza:

- `.pre-commit-config.yaml`: checks antes de cada commit.
- `.github/workflows/ci.yml`: checks en GitHub al hacer push o PR.
- `scripts/check_encoding.py`: detector de texto roto por encoding.

## Si Quieres Saber Qué Skills Hay

Mira:

```text
INDEX.json
```

Ese catálogo se genera desde los `SKILL.md`. No se edita a mano.

Skills actuales:

- `audit-board`: auditoría adversarial multi-rol.
- `backend-automation`: scripts backend, scraping, ETL, tareas recurrentes.
- `memory-keeper`: memoria portable del proyecto en Markdown.
- `multi-agent-collaboration`: coordinación entre varios modelos/agentes, incluido
  el bucle Director/Sonnet -> Codex -> tests -> reporte.
- `project-bootstrap`: arrancar proyectos nuevos.
- `project-guardrails-audit`: auditar repos existentes contra el catálogo de `ci-templates/` para decidir qué aplica y detectar huecos sin sobrescribir a lo bruto.
- `skill-development-framework`: crear o revisar skills.
- `skill-finder`: buscar si ya existe una skill para una tarea.

Si cambias o añades una skill:

```bash
python scripts/build_index.py
python scripts/build_index.py --check
```

## Si Quieres Crear Una Skill Nueva

No empieces creando carpetas.

Primero usa:

```text
skill-development-framework
```

Regla práctica:

```text
Si solo lo usarás una vez -> no es skill.
Si es específico de un proyecto -> va en ese proyecto.
Si es una práctica global y repetida -> puede ser skill.
Si es determinista -> mejor CI/script/hook.
```

Una skill nueva solo debería entrar en `biblio_skills` cuando el patrón ya fue
usado y validado varias veces.

## Si Estás Trabajando Día A Día

Normalmente no llamas a todo manualmente. El reparto es:

- Las `rules/` están siempre de fondo.
- Las `skills/` se activan cuando el agente detecta que aplican.
- Los `workflows/` se invocan a mano, por ejemplo `/cierre`.
- Los checks de `ci-templates/` se ejecutan por Git, pre-commit o GitHub Actions.

Ejemplo de cierre de sesión:

```text
/cierre
```

Eso solo funciona si el workflow fue instalado en el proyecto actual.

## Si Quieres Que Sonnet Dirija Y Codex Codifique

Usa:

```text
multi-agent-collaboration
```

El patrón recomendado es:

```text
Sonnet/Director escribe una tarea en docs/tasks/codex/
Codex lee la tarea, codifica, crea o ajusta tests y ejecuta los tests
Codex rellena el handoff con cambios, comandos y resultado verificable
Sonnet/Director revisa y marca DONE o devuelve correcciones
```

No es para todo. Úsalo cuando quieras separar dirección y ejecución, o cuando el
trabajo sea lo bastante grande como para necesitar una spec persistente. Para fixes
triviales, un solo agente puede bastar.

## Qué Hacer En Cada Caso

| Caso | Qué usar |
| --- | --- |
| Estreno PC | `setup/bootstrap-machine.sh` |
| Quiero que Antigravity vea la biblioteca | `install.ps1` o `install.sh` |
| Empiezo un repo nuevo | `project-bootstrap` |
| Quiero auditar qué checks de CI/guardrails aplicar en un repo | `project-guardrails-audit` |
| Quiero checks automáticos de forma manual en un repo | `ci-templates/` (vía `project-guardrails-audit` si no sabes qué aplica) |
| Quiero guardar memoria portable | `memory-keeper` |
| Quiero que Sonnet dirija y Codex implemente/tests | `multi-agent-collaboration` |
| Quiero revisar un sistema con dureza | `audit-board` |
| Quiero crear una skill | `skill-development-framework` |
| No sé si ya hay una skill | `skill-finder` |

## Regla Final

No copies conocimiento por copiar.

Usa esta lógica:

```text
Máquina nueva      -> bootstrap
Biblioteca global  -> install
Proyecto nuevo     -> project-bootstrap
Checks del proyecto -> ci-templates
Conocimiento reusable -> skills
Juicio universal   -> rules
```
