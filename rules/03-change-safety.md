# Seguridad del cambio

**Antes de editar una función/clase/módulo existente:**

1. Lee la firma original (nombre, parámetros, tipos de retorno).
2. Identifica todos los callers (`grep` o equivalente).
3. Verifica compatibilidad con cada caller — no asumas que "se ve obvio".
4. Cualquier cambio de firma es un cambio de contrato: documéntalo y verifica todos
   los callers antes de proceder.

El cambio debe ser **quirúrgico** (mínima superficie). No refactorices módulos
completos sin requerimiento explícito.

**Al introducir o renombrar un concepto, ruta o convención**, busca en el repo las
referencias al anterior (`grep`) y actualízalas en la **misma pasada**. Incluye la
documentación normativa (README, reglas, AGENTS.md): una convención nueva que convive con la
vieja en otro fichero es una contradicción, no una mejora. Termina con un `grep` del término
viejo para confirmar que no quedan referencias sueltas.

**Diagnostica antes de parchear.** Si se reporta un error, no apliques un fix rápido:
analiza la causa raíz. Un parche que oculta el problema es peor que no hacer nada.

**Código sobre documentación.** Antes de actuar sobre cualquier afirmación documental
(README, docstring, whitepaper, AGENTS.md) que describa un comportamiento concreto,
lee el código y verifica que es correcta. La documentación es una hipótesis hasta
que se verifica; el hallazgo real es el código. Al detectar divergencia, corrige el
documento o el código según cuál sea incorrecto — ignorar la discrepancia no es opción.

**Excepción: documentos normativos.** Si el documento es *normativo* (un contrato, una
especificación, una política o una constitución que dicta lo que el código DEBE hacer), la
divergencia es una presunción de que el **código** está mal, no el documento. No "ajustes"
el contrato para que cuadre con el código sin autorización explícita: verifica cuál refleja
la intención y corrige el código si es él quien se desvía.
