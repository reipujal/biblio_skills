# Tests

- Los tests se escriben en la **misma entrega** que la funcionalidad, no en un paso
  posterior. Cubrir mínimo: happy path + 2-3 casos adversos (input inválido, estado
  límite, fallo esperado).
- Marca correctamente los tests que requieren red o servicios externos
  (ej. `@pytest.mark.integration`).
- Antes de declarar una tarea completada, la suite pasa al 100%. Un test en rojo
  **bloquea** el cierre. Si un fallo es deuda preexistente ajena al cambio, se
  documenta explícitamente — nunca se silencia.

Razón: el test escrito junto al código es el que de verdad refleja la intención;
añadido después tiende a ratificar lo que hay en vez de comprobarlo.

[CI] "Suite verde antes de cerrar" se enforca como gate de CI sobre el PR
(ver `ci-templates/github-actions-ci.yml`). La regla aquí es el estándar; el gate
es el que bloquea.
