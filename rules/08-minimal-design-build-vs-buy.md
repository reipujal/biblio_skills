# Diseño mínimo y build-vs-buy

Aplica a capacidades **no triviales**: las que vas a mantener, las que tienen una alternativa
madura conocida, o las que cuestan un esfuerzo material. Por debajo de ese umbral (una función
corta, un script de un solo uso) construye y sigue — exigir este gate a lo trivial es la misma
burocracia anticipada que esta regla evita.

**Empieza por lo mínimo.** Propón la solución más pequeña que satisface el objetivo declarado.
Añade complejidad solo por un requisito concreto o un riesgo conocido, específico y plausible
—ponderado por su impacto: baja probabilidad con impacto grave (pérdida de datos, secreto
expuesto, acción irreversible) cuenta—. No uses riesgos genéricos para justificar frameworks,
abstracciones o automatización anticipada.

**"No hacer nada" es una opción.** Cuando evalúes crear, ampliar o extraer una capacidad,
comprueba primero si el repo ya cubre el caso con una regla, skill, workflow, plantilla CI o
memoria. Si está cubierto y no hay hueco real, responde "no" y referencia la fuente existente. Sé adversativo con tus propuestas. Ser adversativo no significa buscar una razón para no hacer nada: significa exigir que
cada cambio tenga un beneficio concreto.

**Quitar es mejor que añadir (Borrado Positivo).** Ejerce explícitamente la libertad de proponer la eliminación de código muerto, código comentado (zombie), features obsoletas o abstracciones sin uso demostrable. A menudo, la mejor manera de refactorizar o estabilizar un código problemático heredado no es rodearlo de más lógica protectora, sino proponer su eliminación directa.

**Reutilizar antes de construir.** Antes de implementar una capacidad propia —métrica, harness,
pipeline, evaluador, parser, orquestador, extractor, integración— revisa si existe una
herramienta, librería, estándar o patrón maduro que ya resuelva la parte genérica.

**Entregable previo (antes de construir a medida).** Declara, una línea cada uno:
1. la solución existente conocida, o "ninguna conocida";
2. por qué no basta;
3. qué parte es específica del dominio;
4. qué coste de mantenimiento introduces.
Si no has investigado prior art real, dilo.

**Construye solo lo diferencial.** No repliques infraestructura resuelta. Construye solo la capa
específica: reglas de negocio, adaptación al dominio, integración local, formato de salida o
restricciones propias.

**Sospecha de lo inventado — pero cierra el bucle.** Si propones un enfoque que no ves usado en
producción, asume primero que PUEDE haber una razón (coste, fragilidad, mantenimiento, seguridad,
escala, bugs ya resueltos) e investígala. Si tras investigarla no aparece, adoptarlo es legítimo:
documenta por qué. La novedad no es un defecto; la novedad **no investigada** sí.

**Riesgos y decisión explícitos.** Antes de recomendar un diseño relevante, declara los riesgos
principales (diseño, ejecución, operación, reversibilidad) — identificarlos no obliga a
mitigarlos, solo a no ocultarlos. Si construyes a medida pese a existir alternativa madura,
documenta la alternativa descartada, el trade-off aceptado y qué haría reconsiderar la decisión.
