---
name: multi-agent-collaboration
maturity: validated
description: Protocolo para coordinar varios modelos LLM sobre un mismo proyecto con roles separados (director / ejecutor / auditor independiente). Úsala cuando un proyecto use más de un modelo —p.ej. un modelo que dirige y genera prompts, otro que ejecuta, y un tercero que audita—, cuando se hable de "segunda opinión", "auditoría cruzada", "revisión por otro modelo", "handoff entre modelos", o se diseñe gobierno de colaboración entre IAs. NO la apliques en proyectos mono-agente.
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
  bucle de revisión. NO necesitas handoffs de copia-pega manual.
- **En herramientas separadas** (Claude Code + Codex CLI + Gemini web): la coordinación
  es manual; el humano hace de bus pasando contexto y reports. Mucho del plumbing
  (estados `blocked_by`, plantillas de handoff) existe solo para suplir la falta de un
  harness compartido — si migras todo a Antigravity, ese plumbing se elimina.

Lo que sobrevive en ambos mundos: el principio de juez no-único, el anti-theater, los
niveles de acceso y la Definition of Ready/Done. Eso es lo que esta skill conserva.
