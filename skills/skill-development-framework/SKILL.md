---
name: skill-development-framework
maturity: beta
description: Metodología canónica para crear, revisar y evolucionar skills de agentes LLM en biblio_skills. Úsala SIEMPRE que el usuario quiera crear una skill nueva, decidir si algo merece ser una skill, estructurar o refactorizar una skill existente, o revisar la calidad de una skill — aunque no diga explícitamente "skill". Si detectas un patrón de trabajo reutilizable que podría industrializarse, consulta esta skill antes de proponer estructura.
---

# Skill Development Framework

Define cómo se crean y evolucionan las skills de este repositorio. Es la
implementación de referencia: cualquier skill nueva sigue esta pauta.

No define el gobierno del repo (eso es `AGENTS.md`).

## Qué es una skill

Un módulo de conocimiento reutilizable que permite a un agente realizar de forma
consistente una **familia coherente de tareas**, cargado bajo demanda cuando la
petición coincide con su `description`.

No es: un prompt largo, un README, una colección de ejemplos, ni documentación
general sin propósito operativo.

## Cuándo crear una skill (las cuatro condiciones)

Solo si **todas** se cumplen: el conocimiento se reutilizará · el dominio es
estable · aislarlo mejora el mantenimiento · reduce complejidad futura. Si no,
extiende una skill existente o usa documentación de proyecto.

Y la **compuerta de promoción** (`AGENTS.md`): no se promociona a la biblioteca
global hasta haberse validado 2-3 veces en proyectos reales.

## Documentos de una skill

Esta skill usa estructura plana (un fichero por responsabilidad). Solo crea los que
necesites — no inventes estructura para un futuro hipotético.

- **`SKILL.md`** — propósito, alcance, navegación. El `description` del frontmatter
  es el mecanismo de disparo; redáctalo con precisión y un punto "insistente"
  (los modelos tienden a infra-disparar skills). No dupliques aquí el conocimiento
  detallado que vive en otros ficheros.
- **`KNOWLEDGE.md`** — conceptos estables del dominio.
- **`TEMPLATE.md`** — artefactos reutilizables a copiar/adaptar.
- **`CHECKLIST.md`** — gates de calidad y procedimiento de revisión.
- **`DECISIONS.md`** — decisiones arquitectónicas importantes (problema · alternativas
  · elección · beneficios · riesgos).

## Principios de diseño

Un propósito claro · mínima carga cognitiva · sin conocimiento duplicado (referencia
las `rules/`, no las copies) · independiente del proveedor de LLM · evolución
incremental · validada por uso real.

## Flujo de creación

1. Define el problema.
2. Decide si una skill está justificada (cuatro condiciones + compuerta).
3. Identifica el conocimiento reutilizable.
4. Diseña la estructura mínima útil.
5. Implementa.
6. Valida contra un caso de uso real.
7. Refactoriza.
8. Registra las decisiones importantes en `DECISIONS.md`.

Para revisar antes de dar por hecha una skill: ver `CHECKLIST.md`.

## Procedimiento operativo (crear una skill nueva)

Sigue esto cada vez que algo merezca ser skill (industrializa "se crea siempre igual"):

1. Comprueba la justificación: ¿las cuatro condiciones? ¿pasó la compuerta de promoción
   (validada 2-3 veces)? Si no, extiende una skill existente o usa documentación de
   proyecto, y para.
2. Comprueba que no existe ya una skill que lo cubra (consulta `INDEX.json` / `skill-finder`;
   reutilizar antes de crear).
3. Crea `skills/<nombre-kebab-case>/` y copia el esqueleto de `TEMPLATE.md`. Solo los
   ficheros necesarios.
4. Redacta el `description` con QUÉ + CUÁNDO y tono insistente. Referencia las `rules/`
   comunes en vez de copiarlas.
5. Valida contra un caso de uso real.
6. Pasa el `CHECKLIST.md`. Registra decisiones en `DECISIONS.md`.
7. Regenera el catálogo: `python scripts/build_index.py` (para que `skill-finder` la encuentre).
8. Cierra la sesión (commit + push + STATE).

## Anti-patrones

Un único Markdown gigante · framework antes que evidencia · explosión de carpetas ·
arquitectura dirigida por ejemplos · copiar reglas entre skills · **herencia/jerarquía
entre skills** (las skills son planas; se componen por referencia, no por extensión) ·
asunciones específicas de una tecnología salvo que la skill lo sea explícitamente.

## Prioridad de decisión

1. Correctitud · 2. Simplicidad · 3. Mantenibilidad · 4. Reutilización · 5. Escalabilidad.
