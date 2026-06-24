# Nueva skill

Descripción: arranca la creación de una skill nueva siguiendo la metodología canónica.
Invocar con `/nueva-skill`. Industrializa el "cada vez que algo merezca ser skill, se
crea igual".

Pasos:

1. Carga la skill `skill-development-framework`.
2. Comprueba la justificación: ¿se cumplen las cuatro condiciones? ¿ha pasado la
   compuerta de promoción (validada 2-3 veces)? Si no, propón extender una skill
   existente o usar documentación de proyecto, y detente.
3. Comprueba que no existe ya una skill que cubra esto (reutilizar antes de crear).
4. Crea el directorio `skills/<nombre-kebab-case>/` y copia el esqueleto de
   `TEMPLATE.md`. Crea solo los ficheros necesarios.
5. Redacta el `description` del frontmatter con QUÉ + CUÁNDO y tono insistente.
   Referencia las `rules/` comunes en vez de copiarlas.
6. Valida contra un caso de uso real.
7. Pasa el `CHECKLIST.md`. Registra decisiones relevantes en `DECISIONS.md`.
8. Regenera el catálogo: `python scripts/build_index.py` (para que `skill-finder` la encuentre).
9. Cierra con `/cierre`.
