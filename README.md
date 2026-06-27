# biblio_skills

`biblio_skills` es la biblioteca central de activos reutilizables para agentes
LLM: reglas universales, skills, workflows, plantillas de CI y piezas mínimas de
bootstrap.

Su función no es guardar prompts. Su función es evitar que cada proyecto vuelva a
inventar, copiar y degradar las mismas prácticas operativas. Lo que vive aquí se
consume por referencia, se instala mediante enlaces o bloques gestionados, y se
mantiene como una única fuente de verdad.

## Qué Es

Este repositorio separa cuatro tipos de conocimiento que suelen mezclarse:

| Activo | Cuándo se activa | Dónde vive | Propósito |
| --- | --- | --- | --- |
| Regla | Siempre | `rules/` | Criterios universales de trabajo: seguridad, tests, cambio mínimo, dependencias, cierre. |
| Skill | Cuando la petición encaja con su `description` | `skills/` | Procedimientos reutilizables para familias concretas de tareas. |
| Workflow | Cuando el usuario invoca `/nombre` | `workflows/` | Rutinas explícitas de sesión o proyecto. |
| Plantilla CI | En hooks, commits o PRs | `ci-templates/` | Gates deterministas que una máquina puede comprobar. |

La regla de diseño es simple: **el juicio va en reglas o skills; lo comprobable va
en CI o scripts**.

## Qué No Es

- No es un repositorio de prompts largos.
- No es un cementerio de ideas futuras.
- No es una jerarquía de skills base y skills hijas.
- No es el lugar para conocimiento específico de un proyecto.
- No es un sustituto de linters, tests, hooks o CI.

Una práctica solo debería promocionarse aquí cuando ya fue usada y validada en
proyectos reales. La ruta esperada es:

```text
descubrimiento -> validación (2-3 usos) -> extracción -> promoción -> instalación -> reutilización
```

## Mapa Del Repositorio

```text
biblio_skills/
├── AGENTS.md                  # gobierno del repo: rol del agente, principios y DoD
├── README.md                  # puerta de entrada conceptual
├── INDEX.json                 # catálogo autogenerado de skills
├── install.ps1                # conexión Windows: junctions y bloque de rules
├── install.sh                 # conexión WSL/Linux: symlinks y bloque de rules
├── rules/                     # reglas universales, siempre activas
├── skills/                    # skills reutilizables, cargadas bajo demanda
├── workflows/                 # workflows invocables; Antigravity no los carga globalmente
├── ci-templates/              # pre-commit, CI y checks copiables por proyecto
├── setup/                     # bootstrap global de máquina y plantilla de stack Python
├── scripts/                   # mantenimiento del repo, como build_index.py
└── docs/
    ├── guides/                # guías de instalación, depuración y uso
    └── ANTIGRAVITY.md         # mecánica verificada de Antigravity
```

## Por Dónde Empezar

| Situación | Lee |
| --- | --- |
| Instalar un PC desde cero | [`docs/guides/bootstrap-windows.md`](docs/guides/bootstrap-windows.md) |
| El bootstrap falló y quieres ayuda de un LLM | [`docs/guides/bootstrap-debug-llm.md`](docs/guides/bootstrap-debug-llm.md) |
| Entender qué es cada pieza del repo | [`docs/guides/repository-map.md`](docs/guides/repository-map.md) |
| Saber cómo Antigravity carga rules, skills y workflows | [`docs/ANTIGRAVITY.md`](docs/ANTIGRAVITY.md) |
| Diseñar o revisar una skill | [`skills/skill-development-framework/`](skills/skill-development-framework/) |
| Aplicar checks automáticos a un proyecto | [`ci-templates/README.md`](ci-templates/README.md) |

Camino feliz de instalación:

```text
instalar Antigravity -> descargar biblio_skills -> ejecutar bootstrap-machine -> trabajar por chat
```

El detalle paso a paso está en la guía de instalación. El README no intenta
repetirlo para no crear dos fuentes de verdad.

## Activos Principales

Las reglas universales están indexadas en `rules/00-index.md`. Son pocas a
propósito: si todo es una regla crítica, nada lo es. Cubren secretos, tests,
seguridad del cambio, dependencias, git/cierre, disciplina de razonamiento,
descubrimiento de skills y diseño mínimo.

Las skills disponibles están catalogadas en `INDEX.json`, generado desde el
frontmatter de cada `skills/<nombre>/SKILL.md`. Hoy el catálogo incluye:

- `audit-board`
- `backend-automation`
- `memory-keeper`
- `multi-agent-collaboration`
- `project-bootstrap`
- `project-guardrails-audit`
- `skill-development-framework`
- `skill-finder`

Si añades o cambias una skill, regenera el catálogo:

```bash
python scripts/build_index.py
python scripts/build_index.py --check
```

## Bootstrap E Instalación

`setup/bootstrap-machine.ps1` y `setup/bootstrap-machine.sh` son el botón de
máquina nueva. Preparan el toolchain global y después conectan `biblio_skills`
con Antigravity.

Resumen de lo que dejan preparado:

- Git y GitHub CLI.
- `uv`, Python gestionado por `uv`, `pre-commit`, `detect-secrets` y `ruff`.
- Node.js/npm y CLIs LLM auxiliares: `codex`, `claude`, `gemini`.
- Poppler para trabajo con PDFs.
- Rules y skills visibles para el agente nativo de Antigravity.

`install.ps1` e `install.sh` son solo la conexión/refresco de la biblioteca: enlazan
skills, propagan rules y pueden instalar workflows por proyecto. Para una máquina
nueva, usa el bootstrap; para refrescar una instalación existente, usa `install.*`.

Los workflows, incluido `/cierre`, no son globales en Antigravity: se instalan en
cada proyecto. La explicación completa vive en
[`docs/guides/repository-map.md`](docs/guides/repository-map.md).

## Reglas De Evolución

Antes de añadir algo:

1. Comprueba si ya existe una regla, skill, workflow o plantilla que lo cubra.
2. Reutiliza o modifica la fuente existente antes de crear otra.
3. Si parece una skill nueva, aplica `skills/skill-development-framework/`.
4. Si es determinista, conviértelo en check, hook o CI, no en recordatorio para el LLM.
5. Si es específico de un proyecto, déjalo en ese proyecto.

Una contribución está cerrada solo cuando preserva la consistencia del repo,
evita duplicación, mantiene la documentación afectada y no aumenta complejidad
sin necesidad.

## Lectura Adversativa

El riesgo principal de este repo es traicionar su propia misión: crecer por
entusiasmo, duplicar criterio entre documentos o convertir conocimiento operativo
en prosa que nadie ejecuta. Por eso el diseño favorece activos pequeños, planos,
referenciables y con dueño claro.

El README debe ser una brújula, no el manual completo. Las fuentes especializadas
son:

- Instalación paso a paso: `docs/guides/bootstrap-windows.md`
- Depuración del bootstrap para LLM: `docs/guides/bootstrap-debug-llm.md`
- Uso del repositorio: `docs/guides/repository-map.md`
- Gobierno del repositorio: `AGENTS.md`
- Diseño de skills: `skills/skill-development-framework/`
- Mecánica de Antigravity: `docs/ANTIGRAVITY.md`
- Barreras deterministas por proyecto: `ci-templates/README.md`
