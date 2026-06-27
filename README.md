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

## Primera Instalación De Máquina

La secuencia esperada es:

```text
instalar Antigravity -> clonar/descargar biblio_skills -> ejecutar bootstrap-machine -> vivir en chat
```

`setup/bootstrap-machine.*` es el botón único de máquina nueva: verifica/instala
el toolchain global, comprueba GitHub CLI, prepara Python, instala CLIs globales
y CLIs LLM auxiliares, verifica Poppler y después conecta `biblio_skills` con
Antigravity llamando a `install.*`.
Si Git aún no está disponible, el repo puede descargarse como ZIP; el bootstrap
dejará Git y GitHub CLI instalados para el trabajo posterior.

Windows:

```powershell
pwsh -File setup\bootstrap-machine.ps1
```

WSL/Linux:

```bash
./setup/bootstrap-machine.sh
```

Qué deja preparado:

| Capa | Resultado |
| --- | --- |
| Sistema | Git, GitHub CLI, `uv`, Node.js/npm, Poppler |
| Python global | Python gestionado por `uv` |
| CLIs globales aisladas | `pre-commit`, `detect-secrets`, `ruff` |
| CLIs LLM auxiliares | `codex`, `claude`, `gemini` |
| Antigravity | skills y rules de `biblio_skills` visibles para el agente nativo |
| Proyecto opcional | workflows con `-Project <repo>` o `--project <repo>` |

## Refrescar La Biblioteca

El repositorio es la fuente de verdad. La conexión no crea copias manuales de los
activos reutilizables; los enlaza o escribe bloques gestionados. Si la máquina ya
está preparada y solo quieres refrescar rules/skills:

```powershell
pwsh -File install.ps1
```

```bash
./install.sh
```

Qué conecta:

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

- Instalación paso a paso: `docs/guides/bootstrap-windows.md`
- Depuración del bootstrap para LLM: `docs/guides/bootstrap-debug-llm.md`
- Uso del repositorio: `docs/guides/repository-map.md`
- Gobierno del repositorio: `AGENTS.md`
- Diseño de skills: `skills/skill-development-framework/`
- Mecánica de Antigravity: `docs/ANTIGRAVITY.md`
- Barreras deterministas por proyecto: `ci-templates/README.md`
