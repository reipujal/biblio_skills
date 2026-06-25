---
name: skill-finder
maturity: experimental
description: Router y catálogo de la biblioteca central de skills (biblio_skills). Úsalo cuando ninguna otra skill se haya activado para una tarea y esta sea especializada, cuando el usuario diga "¿hay una skill para esto?", "busca/instala una skill", o cuando detectes un patrón de trabajo recurrente que podría convertirse en skill. NO actúes como segundo router en peticiones triviales o cuando ya hay una skill de dominio activa — eso duplica el routing nativo. Su valor es encontrar skills NO instaladas que el usuario no recuerda.
---

# Skill Finder — router de la biblioteca

Resuelve dos problemas de escala: el usuario no recuerda qué skills existen, e instalarlas
todas saturaría el discovery y ralentizaría el arranque. Solución: un catálogo ligero
(`INDEX.json`) + esta skill que busca, usa, instala o propone crear.

## Localiza la biblioteca (BIBLIO)

`BIBLIO` = ruta en disco del repo `biblio_skills`. No la tienes hardcodeada; dedúcela:
- de las rutas `@.../biblio_skills/rules/...` que aparecen en las reglas activas (GEMINI.md global), o
- del target de cualquier junction en `~/.gemini/antigravity/skills/` (apunta a `BIBLIO/skills/<x>`).

El catálogo está en `BIBLIO/INDEX.json`.

## Procedimiento

1. **Lee el catálogo** `BIBLIO/INDEX.json` (name · description · path de TODAS las skills,
   instaladas o no). Es pequeño; léelo entero.
2. **Empareja** la tarea actual contra las `description` del catálogo. Reporta los 1-3
   candidatos más relevantes, cada uno con una línea de por qué encaja.
3. **Actúa según el caso:**

   **(a) Existe y está instalada** (en `~/.gemini/antigravity/skills/` o en
   `<repo>/.agents/skills/`): úsala con normalidad.

   **(b) Existe pero NO instalada:**
   - *Uso inmediato en este turno:* lee directamente `BIBLIO/<path>/SKILL.md` y sigue sus
     instrucciones ahora. NO necesitas que esté "instalada" para leer y aplicar su contenido.
   - *Uso persistente:* ofrece instalarla (junction). Si el usuario acepta, créala (ver abajo)
     y avísale de que debe reabrir Antigravity o ejecutar `/reload-skills` para que el discovery
     la tome como skill de primera clase.

   **(c) No existe** y la tarea es recurrente/reutilizable: propón crearla con la skill
   `skill-development-framework` (o el workflow `/nueva-skill`). Aplica la compuerta: solo si
   se va a reutilizar 2-3 veces; si es puntual, no crees skill.

4. **No satures:** propón, no instales sin confirmación. Una skill por necesidad real, no "por
   si acaso".

## Instalar una skill (Windows — junctions)

- Global (todos los proyectos): `~/.gemini/antigravity/skills/<x>` -> `BIBLIO/skills/<x>`
- Proyecto (solo este repo; **gana prioridad** sobre la global): `<repo>/.agents/skills/<x>` -> `BIBLIO/skills/<x>`

```powershell
New-Item -ItemType Junction -Path "<destino>\<x>" -Target "<BIBLIO>\skills\<x>"
```

Tras instalar: reabrir Antigravity o `/reload-skills`. (En WSL/Linux: `ln -s`.)

## Mantener el catálogo

`INDEX.json` se regenera con `python BIBLIO/scripts/build_index.py` — no se edita a mano.
Tras crear una skill nueva, regenéralo.
