# DECISIONS — registro de decisiones arquitectónicas

Formato: problema · alternativas · elección · beneficios · riesgos.

## D1 — Estructura plana de ficheros en vez de subdirectorios

- **Problema:** ¿`SKILL.md` + subdirectorios (`knowledge/`, `templates/`…) o ficheros
  planos (`KNOWLEDGE.md`…)?
- **Alternativas:** subdirectorios (más escalable) vs. ficheros planos (menos explosión).
- **Elección:** ficheros planos por defecto; subdirectorios solo si una skill crece.
- **Beneficios:** evita el anti-patrón "explosión de carpetas" para skills pequeñas.
- **Riesgos:** una skill muy grande necesitará reestructurarse; aceptable, es señal de
  que toca dividir.

## D2 — Sin herencia/jerarquía entre skills

- **Problema:** el objetivo inicial pedía "herencia/jerarquías entre skills".
- **Alternativas:** emular herencia (skill base + extensiones) vs. composición por
  referencia.
- **Elección:** composición por referencia + reglas compartidas + subagentes. Nada de
  herencia.
- **Beneficios:** alineado con el modelo de carga por `description` (no hay árbol que
  resolver); evita acoplamiento.
- **Riesgos:** ninguno relevante; la "jerarquía" real es de gobierno (AGENTS.md →
  framework → skills de dominio), no de ejecución.

## D3 — Reglas universales separadas de las skills

- **Problema:** las buenas prácticas globales (tests, secretos…) ¿van dentro de
  `project-bootstrap` o aparte?
- **Alternativas:** dentro de la skill (se activan solo al hacer bootstrap) vs. reglas
  siempre-on.
- **Elección:** `rules/` siempre activas; las skills las **referencian**.
- **Beneficios:** la disciplina aplica a todo proyecto, no solo al arrancarlo; una sola
  fuente de verdad.
- **Riesgos:** saturación de reglas → mitigado manteniéndolas cortas (≤7 hard constraints).

## D4 — Lo determinista a CI, no a prosa

- **Problema:** varias "reglas" (suite verde, secretos, encoding) son comprobables
  mecánicamente.
- **Elección:** el estándar vive en `rules/`; el gate duro en `ci-templates/`.
- **Beneficios:** no se manda a un LLM a hacer el trabajo de un linter; se recupera
  presupuesto de adherencia para las reglas que sí requieren juicio.
- **Riesgos:** doble ubicación (regla + check) → mitigado con referencias cruzadas [CI].
