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
├── install.ps1                # instalación Windows: junctions y bloque de rules
├── install.sh                 # instalación WSL/Linux: symlinks y bloque de rules
├── rules/                     # reglas universales, siempre activas
├── skills/                    # skills reutilizables, cargadas bajo demanda
├── workflows/                 # workflows invocables; Antigravity no los carga globalmente
├── ci-templates/              # pre-commit, CI y checks copiables por proyecto
├── setup/                     # bootstrap global de máquina y plantilla de stack Python
├── scripts/                   # mantenimiento del repo, como build_index.py
└── docs/
    └── ANTIGRAVITY.md         # mecánica verificada de Antigravity
```

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

## Instalación

El repositorio es la fuente de verdad. La instalación no debería crear copias
manuales de los activos reutilizables; debería enlazarlos o escribir bloques
gestionados.

Windows:

```powershell
pwsh -File install.ps1 -DryRun
pwsh -File install.ps1
```

WSL/Linux:

```bash
./install.sh --dry-run
./install.sh
```

Qué instala:

| Origen | Destino |
| --- | --- |
| `skills/<x>/` | `~/.gemini/antigravity/skills/<x>/` |
| `rules/*.md` | bloque gestionado en `~/.gemini/GEMINI.md` |
| `workflows/*.md` | solo por proyecto, con `-Project <repo>` o `--project <repo>` |

Las plantillas de `ci-templates/` no se instalan globalmente. Se copian y ajustan
en cada proyecto porque dependen de su suite, paths y gestor de paquetes.

La mecánica exacta de Antigravity, incluyendo rutas, prioridad entre global y
proyecto, junctions de Windows y límites de workflows globales, vive en
`docs/ANTIGRAVITY.md`.

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

- Gobierno del repositorio: `AGENTS.md`
- Diseño de skills: `skills/skill-development-framework/`
- Mecánica de Antigravity: `docs/ANTIGRAVITY.md`
- Barreras deterministas por proyecto: `ci-templates/README.md`
