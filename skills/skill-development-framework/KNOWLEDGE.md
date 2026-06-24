# KNOWLEDGE — conceptos del diseño de skills

## Los tres niveles de carga (progressive disclosure)

Antigravity (y el formato Agent Skills en general) carga una skill en tres niveles:

1. **Metadatos** (`name` + `description`) — siempre en contexto. Es lo único que el
   agente ve de todas las skills a la vez; por eso el `description` es el mecanismo
   de disparo y debe describir QUÉ hace y CUÁNDO usarse.
2. **Cuerpo de `SKILL.md`** — entra en contexto cuando la skill se dispara. Mantenerlo
   por debajo de ~500 líneas; si crece, añade una capa de jerarquía con punteros claros.
3. **Recursos adjuntos** (`KNOWLEDGE.md`, `TEMPLATE.md`, scripts…) — se leen solo cuando
   hacen falta. Los scripts pueden ejecutarse sin cargarse en contexto.

## Por qué importa el `description`

El agente decide consultar una skill leyendo solo su `description`. Dos fallos típicos:

- **Infra-disparo** (el más común): la skill no se usa cuando sería útil. Mitigación:
  describir contextos concretos de uso, no solo el QUÉ, y un tono ligeramente insistente.
- **Sobre-disparo**: la skill se carga cuando no toca. Mitigación: acotar el alcance en
  el `description`.

Tareas triviales de un paso pueden no disparar ninguna skill aunque el `description`
coincida, porque el agente las resuelve directamente. Las skills se ganan su sitio en
tareas sustantivas, multi-paso o especializadas.

## Composición sin herencia

Las skills no se heredan. Cuando dos skills comparten conocimiento, las opciones son,
en orden de preferencia:

1. Mover el conocimiento común a una **regla** (`rules/`) y referenciarla.
2. Extraerlo a un fichero de conocimiento que ambas referencien.
3. Delegar a un subagente especializado (Antigravity 2.0) cuando es una subtarea aislable.

Nunca: copiar el contenido en ambas skills (deriva garantizada) ni crear una skill
"base" que otras "extienden" (acoplamiento; el modelo de carga es por coincidencia de
`description`, no por resolución de un árbol).

## Regla vs. skill vs. workflow vs. CI

| Si debe activarse…                         | Es un… |
| ------------------------------------------ | ------ |
| siempre, en cualquier proyecto             | regla  |
| solo ante cierta familia de tareas         | skill  |
| solo cuando lo invoco explícitamente       | workflow |
| de forma determinista y comprobable        | check de CI/hook |
