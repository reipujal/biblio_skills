# AGENTS.md — <NOMBRE DEL PROYECTO>

> Gobierno de ESTE proyecto. En Antigravity se lee de forma nativa por cualquier
> modelo. No es un CLAUDE.md.

## Qué es este proyecto
<una o dos frases: objetivo y alcance>

## Reglas globales que aplican
Este proyecto hereda las reglas universales de `biblio_skills/rules/`
(instaladas en el `GEMINI.md` global). En particular son críticas aquí:
- <ej. fail-closed en config de riesgo>
- <ej. tests en la misma entrega>

## Convenciones específicas del proyecto
- Lenguaje / runtime: <ej. Python 3.12+, uv>
- Estructura: <dónde va qué>
- <vocabulario de dominio: si "X" significa algo concreto aquí, decláralo>

## Comandos
- Instalar: `<comando>`
- Tests: `<comando>`
- Ejecutar: `<comando>`

## Reparto de modelos (si es multi-agente)
Si este proyecto usa varios modelos, ver la skill `multi-agent-collaboration`.
Resumen: dirección con el modelo más fuerte; ejecución con Sonnet/Codex; auditoría
independiente (Gemini/GPT) solo en decisiones críticas.

## Definition of Done de este proyecto
- <criterios de cierre específicos, además de la DoD global>
