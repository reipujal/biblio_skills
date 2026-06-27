# Resiliencia y Estabilidad

Prácticas para evitar que la automatización genere deuda técnica, corrumpa datos o entierre errores silenciosamente. Estas previenen los clásicos vicios de programación generativa.

## 1. Falla Rápido y Ruidoso (No Silent Swallows)

Queda **estrictamente prohibido ahogar errores técnicos**. Existe una tendencia patológica en la generación de código a envolver bloques que fallan con `try... except Exception: pass` o `catch (e) {}` genéricos para forzar que el programa no se detenga. 

- Si el código entra en un estado inválido, falta un import, o una dependencia falla, el programa debe **explotar inmediatamente y con ruido** mostrando una traza (stacktrace) clara.
- Una excepción debe propagarse salvo que tengas una estrategia transaccional concreta para mitigarla (ej: reintentos de red).
- Un programa que choca ruidosamente es salvable; un programa que captura sus propios fallos sin registrarlos, genera silenciosamente datos corruptos en la base de datos.

## 2. Idempotencia Rigurosa (En Scripts y Manejo de Datos)

Todo script, tarea de automatización (especialmente en `backend-automation`), pipeline o notebook debe ser **estrictamente idempotente**. Esto significa que ejecutar tu script 1 vez debe generar exactamente el mismo resultado final en el sistema que ejecutarlo 100 veces seguidas.

- Evita usar el modo `append` ciego al generar archivos de salida; reescribe el estado consolidado o averigua qué IDs ya se escribieron para no duplicarlos (esto evita que el usuario tenga un archivo de Excel quintuplicado solo porque testeaste el código cinco veces).
- En bases de datos, utiliza cláusulas preventivas como `UPSERT`, `MERGE` o `ON CONFLICT` en lugar de `INSERT` a ciegas.
- Si envías correos masivos o haces llamadas destructivas a APIs, mantén un registro de "ya procesado" antes del envío real. 
- Debes codificar asumiendo que el script fallará en el registro 50 de 100 por un problema de red, y el usuario lo re-ejecutará desde el principio esperando que tu script sepa qué omitir.
