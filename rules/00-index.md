# Reglas universales

Reglas **siempre activas** en cualquier proyecto. Cortas a propósito: si esto se
infla, ninguna regla aterriza. Hard constraints ≤ ~7.

Lo **determinista** (¿pasan los tests? ¿hay un secreto suelto? ¿UTF-8?) no se
confía a la memoria del agente: se enforca en `ci-templates/`. Aquí va el
**estándar y el criterio**; el gate duro vive en CI. Cada regla marca [CI] cuando
tiene un enforcement automático asociado.

| Fichero                     | Cubre                                                        |
| --------------------------- | ----------------------------------------------------------- |
| `01-secrets-and-safety.md`  | secretos fuera del código; fail-closed en config crítica    |
| `02-testing.md`             | tests en la misma entrega; suite verde antes de cerrar [CI] |
| `03-change-safety.md`       | verificar callers; cambio quirúrgico; código sobre docs     |
| `04-dependencies.md`        | versiones fijadas; requirements al día [CI]                 |
| `05-git-and-session.md`     | commit + push al cerrar; protocolo de pausa larga           |
| `06-reasoning-discipline.md`| exploración vs. confirmación; hechos vs. hipótesis; síntoma vs. causa; cierre razonado |
| `07-skill-discovery.md`     | consultar el catálogo de skills antes de improvisar         |
| `08-minimal-design-build-vs-buy.md` | empezar por lo mínimo; reutilizar antes de construir; riesgos explícitos |

Excepción transversal a todas: sesiones de solo lectura, exploración o cambios
exclusivos de documentación quedan exentas de los gates de cierre.
