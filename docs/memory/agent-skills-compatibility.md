---
name: agent-skills-compatibility
description: Adoptar compatibilidad Agent Skills solo cuando simplifique mantenimiento o interoperabilidad real
metadata:
  type: project
---

En `biblio_skills`, la compatibilidad con Agent Skills se adopta de forma selectiva:
validar `name` y `description`, documentar recursos relativos y preferir `scripts/`
para scripts reutilizables nuevos. No reorganizar skills existentes solo para parecer
más estándar.

`maturity` se mantiene por ahora como campo local top-level porque alimenta `INDEX.json`
y es más simple para uso personal. Reconsiderar moverlo a `metadata.biblio_maturity`
solo si se busca pasar validadores externos estrictos o distribuir las skills fuera del
ecosistema local.

No añadir `compatibility` por defecto. Usarlo solo en una skill concreta si depende de
un harness, producto o herramienta de entorno de forma no obvia.

**Why:** La regla 08 prioriza reutilizar el estándar solo donde reduzca mantenimiento,
mejore interoperabilidad o evite duplicidad. Para un único desarrollador, migraciones
estéticas a `references/`, `assets/`, `metadata` o un harness completo de evals generan
coste sin beneficio diario claro.

**How to apply:** Al crear o revisar skills, pasar primero por
`skills/skill-development-framework/CHECKLIST.md` y `python scripts/build_index.py --check`.
Si aparece una presión real de interoperabilidad externa, reabrir explicitamente las
decisiones pendientes: `maturity` dentro de `metadata` y uso caso a caso de `compatibility`.
