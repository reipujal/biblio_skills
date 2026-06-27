---
status: TODO
title: <titulo breve>
created: <YYYY-MM-DD>
owner: codex
reviewer: director
---

# <Titulo>

## Objetivo

<Resultado observable que debe quedar conseguido. Debe poder revisarse con tests,
un archivo producido, una salida reproducible o un cambio concreto en disco.>

## Contexto

<Por que existe esta tarea. Incluir enlaces o rutas concretas. Evitar narrativa larga.>

## Archivos Autorizados

- `<ruta>`
- `tests/<ruta>`

## Archivos Protegidos

- `<ruta que Codex no debe tocar>`

## Cambios Esperados

1. <Cambio concreto>
2. <Cambio concreto>
3. <Tests o fixtures a crear/actualizar>

## Tests Esperados

Comandos exactos que Codex debe ejecutar:

```bash
<comando de test>
```

Si no hay tests razonables, justificar aqui que output binario sustituye al test.

## Output Requerido

- <archivo, comando, fixture o evidencia que debe existir al final>

## Criterio De Cierre

La tarea puede pasar a `TO_REVIEW` solo si:

- Los cambios esperados estan implementados.
- Los tests esperados se han ejecutado.
- El output requerido existe o la razon de ausencia esta documentada.
- No se han tocado archivos protegidos.

## Preguntas Para Director

<Solo si Codex necesita una decision que no le corresponde. Si hay preguntas
bloqueantes, cambiar `status:` a `QUESTION` y no implementar.>

## Correcciones

<El director escribe aqui instrucciones si devuelve la tarea de `TO_REVIEW` a `TODO`.
Codex debe leer esta seccion antes de re-ejecutar y reemplazar el handoff anterior.>

## Handoff A Director

Codex rellena esta seccion al terminar:

```text
Cambios realizados:
- <archivo>: <resumen>

Tests ejecutados:
- <comando exacto> -> <resultado>

Output binario producido:
- <archivo/salida/fixture>

Decisiones menores tomadas:
- <si aplica>

Riesgo residual:
- <si aplica>

Criterio de aceptacion:
- <por que esto esta listo para revision>
```
