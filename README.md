# biblio_skills

Biblioteca central y reutilizable de activos para agentes LLM, diseñada para
**Google Antigravity** y pensada para funcionar de forma global en todos los
proyectos. Su objetivo: dejar de re-derivar las mismas buenas prácticas en cada
repo y convertirlas en barreras que previenen errores automáticamente.

## Modelo conceptual

Cuatro tipos de activo, cada uno con un criterio de activación distinto:

- **`rules/`** — Reglas que valen **siempre**, en cualquier proyecto. El agente
  las tiene de fondo sin que se las repitas (secretos, tests, seguridad de cambios…).
  Son las normas pegadas en la pared.
- **`skills/`** — Paquetes de conocimiento que se cargan **bajo demanda**, solo
  cuando la petición coincide con su `description` (progressive disclosure). Son
  las recetas que el agente saca del cajón cuando va a hacer ese plato.
- **`workflows/`** — Secuencias invocables con `/nombre` (slash command).
- **`ci-templates/`** — Barreras **duras**: lo que una máquina puede comprobar
  (tests verdes, secretos, encoding) se enforca en CI/hooks, no se le pide al LLM
  que lo recuerde.

Regla de oro: **prosa para el juicio, automatización para lo determinista.**

## Por qué existe

El problema real no era falta de buenas prácticas, sino que vivían dispersas y
duplicadas (un `CLAUDE.md` global por aquí, un `rules/` por proyecto por allá,
con nombres distintos y deriva entre copias). `biblio_skills` es la **única fuente
de verdad**: cada proyecto la consume por referencia; si mejoras una regla, todos
los proyectos la heredan.

## Mapa del almacén

```
biblio_skills/
├── AGENTS.md                  # gobierno del repo (Antigravity lo lee nativo)
├── README.md                  # este fichero
├── install.sh                 # enlaza activos a las rutas globales de Antigravity
├── INDEX.json                 # catálogo de skills (autogenerado; lo consulta skill-finder)
├── setup/                     # toolchain global de máquina (una vez por PC)
│   ├── bootstrap-machine.sh   # Python fijado + CLIs (uv tool) + check de poppler
│   └── python-stack.txt       # plantilla requirements.in para project-bootstrap
├── scripts/
│   └── build_index.py         # regenera INDEX.json escaneando skills/
├── rules/                     # reglas universales (siempre activas)
├── skills/
│   ├── skill-development-framework/   # meta-skill: cómo crear skills
│   ├── project-bootstrap/             # arrancar un proyecto nuevo bien
│   ├── backend-automation/            # scripts de automatización con TASK.md
│   ├── multi-agent-collaboration/     # director / ejecutor / auditor independiente
│   ├── audit-board/                   # auditoría adversarial multi-rol en paralelo
│   └── skill-finder/                  # router: busca en el catálogo, instala o propone crear
├── workflows/                 # /cierre, /nueva-skill, /auditoria-externa
└── ci-templates/              # pre-commit + GitHub Actions reutilizables
```

## Instalación (global)

`biblio_skills` es la fuente de verdad; `install.sh` enlaza cada activo a la
ubicación que Antigravity consume:

```bash
git clone https://github.com/reipujal/biblio_skills.git
cd biblio_skills
./setup/bootstrap-machine.sh   # una vez por PC: Python, CLIs globales, check de poppler
# Windows nativo (junctions; Antigravity las ve como carpetas):
#   pwsh -File install.ps1            (-DryRun para simular)
# WSL / Linux (symlinks):
#   ./install.sh                      (--dry-run para simular)
```

| Origen              | Destino global de Antigravity                         |
| ------------------- | ----------------------------------------------------- |
| `skills/<x>/`       | `~/.gemini/config/skills/<x>/` (symlink)              |
| `workflows/<x>.md`  | `~/.gemini/antigravity/global_workflows/<x>.md`       |
| `rules/`            | referenciadas/concatenadas en `~/.gemini/GEMINI.md`   |

> Verifica las rutas exactas en tu versión de Antigravity antes de confiar en el
> symlink de rules; si el `@import` absoluto no resuelve desde el `GEMINI.md`
> global, `install.sh` concatena en su lugar (ver el script).

Las `ci-templates/` **no** se instalan globalmente: se copian por proyecto
(ver `ci-templates/README.md`).

## Arquitectura global de Antigravity (dónde vive cada cosa)

Antigravity guarda lo global en tu máquina bajo `~/.gemini/`:

| Activo                 | Ruta global                                      |
| ---------------------- | ------------------------------------------------ |
| Skills globales        | `~/.gemini/antigravity/skills/` (confirmado)     |
| Skills de proyecto     | `<repo>/.agents/skills/` (gana prioridad sobre la global) |
| Reglas personales      | `~/.gemini/GEMINI.md`                            |
| Memoria (KIs)          | `~/.gemini/antigravity/knowledge/`               |
| MCP                    | `~/.gemini/antigravity/mcp_config.json`          |

`biblio_skills/rules/` es la **única fuente de verdad**; `install.sh` escribe un
bloque gestionado en el/los fichero(s) global(es) que uses (`GLOBAL_RULE_TARGETS`).
Un `CLAUDE.md` global (de Claude Code) **no lo lee Antigravity**: si lo conservas,
hazlo que apunte a `biblio_skills/rules/` para que no diverja, o redúcelo. No mantengas
reglas duplicadas en dos ficheros globales distintos.

## Memoria del proyecto (dos capas, sin duplicar)

- **Knowledge Items (KIs)** — mecanismo nativo de Antigravity: un subagente extrae al
  cerrar cada conversación los hechos clave y los carga al inicio de la siguiente.
  Automático, local a la máquina. No inventes un `memory.md` para esto.
- **`docs/STATE.md`** — capa portable y versionada (estado · siguiente acción ·
  decisiones), actualizada en `/cierre`. Es lo que sobrevive a un cambio de PC y lo que
  un auditor externo lee desde GitHub. Mínimo, no un "memory bank" de cinco ficheros.

## Cómo se trabaja (reparto de modelos)

- **Dirección / estrategia** (genera prompts, revisa, decide): el modelo más fuerte
  disponible (Opus).
- **Ejecución** de specs claras: Sonnet.
- **Codificación**: Codex / Sonnet.
- **Auditoría independiente** en decisiones críticas: Gemini o GPT (familia distinta
  = independencia real). Puntual, no en el loop diario.

## Compuerta de promoción

Un patrón no entra en la biblioteca al ocurrírsete. Primero se usa **2–3 veces** en
proyectos reales; si funciona, se extrae, se generaliza (quitando lo específico) y
se promociona aquí. Así el almacén no se llena de recetas no validadas.

## Roadmap (aún NO creadas — se crean cuando un proyecto real las valide)

- `skills/rag-engineering/` — chunking, evaluación de faithfulness, harness de jueces.
- `skills/sap-functional/` — convenciones de provenance, T-codes, frontmatter SAP.
- Más `ci-templates/` por clase de proyecto.

No existen como carpetas vacías a propósito: crear estructura para un futuro
hipotético es el anti-patrón que este repo evita.
