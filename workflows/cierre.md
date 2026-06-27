---
description: Cierra una sesión de trabajo sincronizando el estado con el remote y dejando la suite en verde. Invocar con /cierre cuando hubo cambios de código en disco.
---
# Cierre de sesión

Pasos:

1. Determina si hubo cambios en disco. Si la sesión fue de solo lectura/exploración o
   solo documentación, informa y termina (no aplica el cierre).
2. Ejecuta la suite de tests (`pytest` o equivalente). Si hay rojos:
   - si es deuda preexistente ajena al cambio, documéntalo explícitamente y continúa;
   - si lo introdujo esta sesión, NO cierres: arréglalo primero.
3. `git status` — revisa qué cambió. Comprueba que no se cuelan secretos (claves, `.env`).
4. Actualiza `docs/memory/project-state.md` (capa de memoria portable, regla 05): estado actual ·
   siguiente acción · decisiones abiertas. Corto. (Se actualiza ANTES del commit para que
   entre en él.)
5. Agrupa los cambios en un commit por **unidad lógica** (coherente, verificable,
   revertible — los archivos tocados son indicador secundario; ver regla 05). Incluye
   `docs/memory/project-state.md` en el commit.
6. `git push` al remote. Si no hay remote configurado, avisa: sin push no hay backup.
7. Resume en una línea: qué se hizo, qué quedó abierto, qué mirar al volver.
