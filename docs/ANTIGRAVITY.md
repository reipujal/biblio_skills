# Mecánica de Antigravity (verificada empíricamente)

Cómo Antigravity carga rules, skills y workflows, y cómo `biblio_skills` los distribuye.
Todo lo de aquí está **confirmado en máquina** (no de documentación, que se contradice
entre versiones y fuentes). Si algo cambia de versión, re-verificar con las pruebas ping.

## Concepto base: harness ≠ modelo

El **harness** (la herramienta que ejecuta al agente) decide qué ficheros se leen; el
**modelo** (Gemini / Claude / GPT) es intercambiable y NO cambia las rutas. En Antigravity
los tres modelos leen los mismos ficheros del IDE. `CLAUDE.md` es de Claude Code, **Antigravity
no lo lee**. Por eso el gobierno por proyecto va en `AGENTS.md` (que Antigravity sí lee) y, si
acaso, importa `CLAUDE.md` con `@import`.

> **Trampa de panel (causa de confusión real, dos veces).** En la ventana conviven DOS agentes:
> el panel **Claude Code** (slash commands propios: `/context`, `/compact`, `/usage`…; lee
> `~/.claude/skills/`) y el panel **agente nativo (Gemini)** a la derecha (campo "Ask anything,
> / for workflows"; lee `~/.gemini/antigravity/skills/` y `<repo>/.agents/workflows/`). Las
> skills y workflows de biblio_skills SOLO aparecen en el panel Gemini. Si pruebas `/cierre` o
> `/skills` en el panel Claude Code, NO saldrán — no es un bug, es el panel equivocado. **Verifica
> siempre en el panel del agente Gemini.**

Hay **dos sistemas de skills conviviendo** en la máquina, según el harness:
- Panel **Claude Code** dentro de Antigravity → lee `~/.claude/skills/`.
- Agente **Antigravity nativo** (Gemini) → lee `~/.gemini/antigravity/skills/`.
El comando `/reload-skills` del panel Claude Code lista las de `~/.claude/skills/`, NO las
nativas. Para ver las nativas, preguntar al agente Gemini "qué skills tienes disponibles".

## Los tres activos: activación y distribución

| Activo | Activación | Ruta que Antigravity escanea | ¿Global? |
| ------ | ---------- | ---------------------------- | -------- |
| **Rules** | siempre-on (texto en contexto) | `~/.gemini/GEMINI.md` (global) · `<repo>/.agents/rules/` (proyecto) | **Sí** (global) ✅ verificado |
| **Skills** | bajo demanda (match de `description`) | `~/.gemini/antigravity/skills/` (global) · `<repo>/.agents/skills/` (proyecto, gana prioridad) | **Sí** (global) ✅ verificado (ping PONG) |
| **Workflows** | invocación explícita `/nombre` | `<repo>/.agents/workflows/` (SOLO workspace) | **No** ✗ verificado: no hay global |

Memoria nativa (Knowledge Items): `~/.gemini/antigravity/knowledge/` (automática, local).
MCP: `~/.gemini/antigravity/mcp_config.json`.

Workflows: Antigravity escanea 4 variantes de carpeta — `.agents/workflows`, `.agent/workflows`,
`_agents/workflows`, `_agent/workflows` (usamos la primera). El `.md` DEBE empezar con frontmatter
`--- / description: ... / ---` o no se registra como slash command (una "Descripción:" en prosa no
cuenta).

## Implicaciones de diseño

- **Rules universales → global** vía bloque gestionado en `~/.gemini/GEMINI.md` (lo escribe
  `install.ps1` referenciando `biblio_skills/rules/*` con `@ruta`). Rules de dominio → en el
  `.agents/rules/` del proyecto.
- **Skills reutilizables → global** vía junctions en `~/.gemini/antigravity/skills/`. Skills de
  proyecto → en `<repo>/.agents/skills/` (gana prioridad sobre la global con el mismo nombre).
- **Workflows no pueden ser globales.** Por eso los procedimientos que eran `/nueva-skill` y
  `/auditoria-externa` se **plegaron en skills** (skill-development-framework y
  multi-agent-collaboration): así son globales gratis. Solo `cierre` queda como workflow, y se
  instala por proyecto en `.agents/workflows/` (paso opcional de `install.ps1 -Project <repo>`).

## Windows: junctions, no symlinks

`install.ps1` crea **junctions** de directorio (`New-Item -ItemType Junction`): no requieren
modo desarrollador ni admin, y Antigravity las ve como carpetas normales. Los symlinks POSIX
(`ln -s` de `install.sh`) son para WSL/Linux. El contenido vive en `biblio_skills`; las
junctions solo enlazan, no copian → una sola fuente de verdad.

## Pruebas de verificación (si cambia de versión)

- **Skill global:** crear `~/.gemini/antigravity/skills/ping-test/SKILL.md`, reabrir, invocar.
- **Workflow:** crear `<repo>/.agents/workflows/ping.md` con frontmatter `description:`, reabrir,
  escribir `/` en el agente Gemini.
- **Regla global:** pedir algo que viole una regla (ej. hardcodear un secreto) y ver si la corta.
