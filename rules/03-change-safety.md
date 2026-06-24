# Seguridad del cambio

**Antes de editar una función/clase/módulo existente:**

1. Lee la firma original (nombre, parámetros, tipos de retorno).
2. Identifica todos los callers (`grep` o equivalente).
3. Verifica compatibilidad con cada caller — no asumas que "se ve obvio".
4. Cualquier cambio de firma es un cambio de contrato: documéntalo y verifica todos
   los callers antes de proceder.

El cambio debe ser **quirúrgico** (mínima superficie). No refactorices módulos
completos sin requerimiento explícito.

**Diagnostica antes de parchear.** Si se reporta un error, no apliques un fix rápido:
analiza la causa raíz. Un parche que oculta el problema es peor que no hacer nada.

**Código sobre documentación.** Antes de actuar sobre cualquier afirmación documental
(README, docstring, whitepaper, AGENTS.md) que describa un comportamiento concreto,
lee el código y verifica que es correcta. La documentación es una hipótesis hasta
que se verifica; el hallazgo real es el código. Al detectar divergencia, corrige el
documento o el código según cuál sea incorrecto — ignorar la discrepancia no es opción.
