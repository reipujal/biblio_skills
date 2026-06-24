# TEMPLATE — esqueleto de una skill nueva

Copia y adapta. Crea solo los ficheros que la skill necesite.

```
skills/<nombre-kebab-case>/
├── SKILL.md            (obligatorio)
├── KNOWLEDGE.md        (si hay conceptos estables que documentar)
├── TEMPLATE.md         (si produce artefactos reutilizables)
├── CHECKLIST.md        (si tiene gates de calidad propios)
├── DECISIONS.md        (si hay decisiones arquitectónicas que registrar)
└── templates/          (ficheros de salida: .gitignore, .env.example, etc.)
```

## SKILL.md base

```markdown
---
name: <nombre-kebab-case>
description: <QUÉ hace> + <CUÁNDO usarse: contextos y frases concretas>. Tono
  ligeramente insistente para combatir el infra-disparo. Sin "cómo usarse" en el
  cuerpo — todo el "cuándo" va aquí.
---

# <Nombre en Title Case>

## Propósito
<una o dos frases>

## Cuándo aplica / cuándo no
<delimitación de alcance>

## Procedimiento
<pasos; referencia rules/ en vez de copiarlas>

## Recursos
<punteros a KNOWLEDGE.md, templates/, scripts; con guía de cuándo leerlos>
```

## Convenciones de nombre

| Concepto            | Convención   | Ejemplo                          |
| ------------------- | ------------ | -------------------------------- |
| Nombre lógico       | Title Case   | Project Bootstrap                |
| Directorio          | kebab-case   | `project-bootstrap`              |
| Fichero de entrada  | siempre      | `SKILL.md`                       |

No nombres el fichero de entrada según la skill. Siempre es `SKILL.md`.
