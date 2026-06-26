# Disciplina de razonamiento

**Exploración vs. confirmación.** La exploración inicial no requiere hipótesis binaria:
sirve para entender un sistema desconocido y formular hipótesis. Antes de un experimento
*confirmatorio*, en cambio, define: (1) pregunta binaria, (2) criterio de éxito, (3) criterio
de falsificación. Si no hay falsificación posible, no lo llames experimento.

**Hechos vs. hipótesis.** Cuando una decisión dependa de información incompleta, separa
hechos observados, inferencias e hipótesis. No construyas sobre hipótesis tratadas como
hechos. Si una hipótesis condiciona el diseño, decláralo.

**Síntoma vs. causa estructural.** Dos disparadores distintos para la misma acción: *parar
y reexaminar*. (1) *Fallo repetido*: el sistema se rompe una y otra vez pese a correcciones
sucesivas → la causa probablemente es estructural, no el último bug. (2) *Deriva de
objetivo*: nada falla, pero la solución solo crece desarrollando la dirección ya iniciada en
lugar de resolver el problema correcto. Señales: las correcciones están al límite del
sistema; un cambio externo *podría explicar* el inicio del fallo (la coincidencia temporal
sugiere, no prueba — investígala); la premisa básica ya no se cumple. Acción en ambos casos:
reexamina las asunciones, reformula el objetivo y compáralo con una alternativa más simple,
en vez de añadir más ajustes.

**Cierre razonado.** Cuando descartes una dirección, feature o rama, documenta por qué se
abandona y qué tendría que cambiar para reconsiderarla. La evidencia negativa evita repetir
callejones sin salida.

> El alcance y la complejidad del diseño (empezar por lo mínimo, build-vs-buy, riesgos
> explícitos) están en la regla 08.
