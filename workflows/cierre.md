# Cierre de sesión

Descripción: cierra una sesión de trabajo sincronizando el estado con el remote y
dejando la suite en verde. Invocar con `/cierre`.

Pasos:

1. Determina si hubo cambios en disco. Si la sesión fue de solo lectura/exploración o
   solo documentación, informa y termina (no aplica el cierre).
2. Ejecuta la suite de tests (`pytest` o equivalente). Si hay rojos:
   - si es deuda preexistente ajena al cambio, documéntalo explícitamente y continúa;
   - si lo introdujo esta sesión, NO cierres: arréglalo primero.
3. `git status` — revisa qué cambió.
4. Agrupa los cambios en un commit con mensaje descriptivo del conjunto
   (sinergia por archivos tocados; ver regla 05).
5. `git push` al remote. Si no hay remote configurado, avisa: sin push no hay backup.
6. Resume en una línea: qué se hizo, qué quedó abierto, qué mirar al volver.
