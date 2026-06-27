---
name: multi-agent-collaboration
maturity: validated
description: Protocolo para coordinar varios modelos LLM sobre un mismo proyecto con roles separados (director / ejecutor / auditor independiente). Úsala cuando un proyecto use más de un modelo —p.ej. Sonnet/Claude como director que escribe requisitos, Codex como ejecutor que codifica/tests, y Gemini/GPT como auditor—, cuando se hable de "segunda opinión", "auditoría cruzada", "revisión por otro modelo", "handoff entre modelos", "Sonnet pide a Codex", "Codex implementa y reporta", colas docs/tasks/codex, o gobierno de colaboración entre IAs. NO la apliques en proyectos mono-agente.
---

# Multi-Agent Collaboration

Coordina varios modelos sobre un proyecto preservando el principio rector:
**ningún modelo es juez único de su propio trabajo.**

Es el núcleo reutilizable de un protocolo de colaboración. Lo específico de un dominio
(fórmulas, presupuestos, universos…) NO va aquí: va en el proyecto.

## Roles

| Rol      | Responsabilidad                                  | Modelo típico |
| -------- | ------------------------------------------------ | ------------- |
| Director | estrategia, genera prompts, revisa, decide       | el más fuerte (Opus) |
| Ejecutor | aplica specs claras, devuelve resultado          | Sonnet / Codex |
| Auditor  | segunda opinión independiente en lo crítico      | Gemini / GPT  |

## Gradiente de independencia (clave)

La independencia del auditor no es binaria, es un gradiente:

- **Débil**: auditor de la misma familia que el constructor (ej. Sonnet revisando a
  Opus). Detecta errores de ejecución, **no** sesgos compartidos por la familia.
- **Fuerte**: auditor de familia y entrenamiento distintos (ej. Gemini/GPT revisando a
  Claude). Captura sesgos que toda la familia comparte.

Regla: reserva la independencia fuerte para **decisiones irreversibles o de governance**;
no la gastes en el loop rutinario. El loop diario se cubre con director+ejecutor y los
gates de CI.

## Anti-theater: cierre con output binario

Un handoff está cerrado **solo** cuando existe output binario verificable:
tests en verde, un fichero de resultados reproducible, o un fixture numérico
documentado (valor esperado vs. calculado). Sin output binario, no está cerrado —
da igual el estado aparente del código.

## Bucle Director -> Codex en Antigravity

Usa este bucle cuando el usuario quiera que Sonnet/Claude dirija y Codex ejecute:

1. **Director define la tarea**: crea una spec pequeña y ejecutable en
   `docs/tasks/codex/<slug>.md` usando `templates/codex-task.md`.
2. **Codex ejecuta**: lee solo las tareas activas en `docs/tasks/codex/*.md`, ignora
   `done/`, implementa dentro de los archivos autorizados, crea/actualiza tests y
   ejecuta los comandos pedidos.
3. **Codex reporta**: cambia la tarea a `TO_REVIEW` y rellena `## Handoff a Director`
   con cambios, tests exactos, output verificable y riesgo residual.
4. **Director revisa**: verifica el output binario. Si acepta, marca `DONE` y mueve
   la tarea a `docs/tasks/codex/done/`. Si no, añade `## Correcciones`, vuelve a
   `TODO` y Codex re-ejecuta.

El director puede ser Sonnet, Claude u otro modelo fuerte. El ejecutor puede ser
Codex CLI, Codex en Antigravity u otro agente de código. Lo importante es el contrato:
spec clara -> ejecución con tests -> reporte verificable -> revisión separada.

### Estados de tarea

| Estado | Quién lo usa | Significado |
| --- | --- | --- |
| `TODO` | Director | Lista para ejecutar por Codex |
| `QUESTION` | Codex | Falta una decisión del director; Codex no debe adivinar |
| `TO_REVIEW` | Codex | Implementado; esperando revisión del director |
| `DONE` | Director | Cerrado y movido a `done/` |
| `BLOCKED` | Director | Espera a usuario, auditor externo u otra tarea |

Regla: Codex no marca `DONE`, no mueve a `done/`, no desbloquea `BLOCKED` y no toca
archivos protegidos. Si la spec no está lista, pone `QUESTION` o reporta la
inconsistencia.

## Niveles de acceso (quién toca qué)

Declara por proyecto qué ficheros son críticos y quién puede modificarlos. Patrón:

- **Solo director/usuario**: constitución, planes, presupuestos, config de riesgo.
- **Requiere handoff explícito**: ficheros con consecuencias de governance.
- **Ejecutor con tests + revisión**: lógica de aplicación.
- **Auditor**: solo lectura; escribe únicamente su report en la sección designada.

## Definition of Ready / Done

- **Ready** (una tarea entra como ejecutable solo si): objetivo binario · ficheros
  autorizados y protegidos · tests esperados · output requerido · criterio de cierre.
- **Done**: output binario verificado + revisión del director + documentación al día.

Para tareas Codex, Ready exige además:

- `status: TODO` en frontmatter.
- archivos autorizados y archivos protegidos explícitos.
- tests esperados o justificación de por qué no hay tests.
- criterio de aceptación observable.
- límites de decisión: qué puede decidir Codex y qué debe devolver como `QUESTION`.

## Procedimiento de auditoría externa (segunda opinión independiente)

Reservado a decisiones irreversibles o de governance; en rutina basta director + ejecutor + CI.

1. Confirma que la decisión justifica independencia fuerte (auditor de familia distinta:
   Gemini/GPT). Si es rutina, no la uses.
2. Define UNA sola pregunta binaria o claim a verificar, con criterio de aceptación
   (binario o cuantitativo, con referencia externa cuando aplique).
3. Reúne el contexto mínimo (ficheros concretos, no "todo el repo"). Si el proyecto es
   público en GitHub, basta el enlace; si no, exporta los ficheros.
4. El auditor entrega un report con: hallazgo + archivo:línea + severidad + razonamiento.
   Prohibido que proponga implementaciones o specs: identifica, no decide.
5. El director evalúa y decide: incorporar, abrir corrección o descartar (con
   justificación). El auditor no modifica ficheros del proyecto.

## Implementación en Antigravity vs. herramientas separadas

- **En Antigravity** (un solo harness, varios modelos): la coordinación es nativa.
  Usa agentes en paralelo (Manager view) o cambio de modelo, y los artifacts como
  bucle de revisión. Para el bucle Sonnet -> Codex, usa `docs/tasks/codex/` como
  contrato persistente: Sonnet escribe specs, Codex ejecuta y reporta, Sonnet cierra.
- **En herramientas separadas** (Claude Code + Codex CLI + Gemini web): la coordinación
  es manual; el humano hace de bus pasando contexto y reports. Mucho del plumbing
  (estados `blocked_by`, plantillas de handoff) existe solo para suplir la falta de un
  harness compartido — si migras todo a Antigravity, ese plumbing se elimina.

Lo que sobrevive en ambos mundos: el principio de juez no-único, el anti-theater, los
niveles de acceso y la Definition of Ready/Done. Eso es lo que esta skill conserva.

## Recursos

- `templates/codex-task.md` — plantilla de tarea para el bucle Director -> Codex.
