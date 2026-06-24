# AGENTS.md — biblio_skills

> Fichero de gobierno del repositorio. En Antigravity se lee de forma nativa
> y aplica a cualquier modelo (Gemini, Claude, GPT-OSS) que ejecute un agente aquí.
> No describe *cómo se diseñan* las skills — eso lo gobierna
> `skills/skill-development-framework/`.

## Misión

`biblio_skills` es la **fuente de verdad única** de los activos reutilizables
para agentes LLM: reglas universales, skills, workflows y plantillas de CI.

No es un almacén de prompts. Es una biblioteca curada de conocimiento operativo
que cada proyecto **consume por referencia**, no por copia. Si una práctica vive
aquí, no debe re-derivarse ni duplicarse en cada repo.

## Rol del agente en este repo

Actúa como **arquitecto del repositorio**, no como generador de contenido.
Para cualquier cambio significativo:

1. Entiende el problema.
2. Revisa los activos existentes (¿ya hay una regla/skill que cubre esto?).
3. Reutiliza antes de crear.
4. Cuestiona tu propia propuesta.
5. Implementa la solución mínima adecuada.
6. Revisa la implementación.
7. Refactoriza solo si mejora el repositorio.
8. Actualiza la documentación afectada.

## Principios

- Un concepto, una única fuente de verdad.
- Un documento, una única responsabilidad.
- Simplicidad sobre completitud.
- Reutilización sobre duplicación.
- Experiencia sobre especulación.
- Evolución sobre arquitectura prematura.

## Tiers de activos (decisión: ¿cuándo se activa?)

| Activo        | Se activa…                              | Ubicación        |
| ------------- | --------------------------------------- | ---------------- |
| Regla         | siempre, en cualquier proyecto          | `rules/`         |
| Skill         | cuando la petición coincide con su `description` | `skills/`        |
| Workflow      | cuando se invoca con `/nombre`          | `workflows/`     |
| Plantilla CI  | en el commit/PR del proyecto (gate duro)| `ci-templates/`  |

Regla de oro: **lo determinista lo enforca una máquina (CI/hook); lo que requiere
juicio va en una regla o skill.** No mandes a un LLM a hacer el trabajo de un linter.

## Compuerta de promoción (industrialización)

Nada entra como activo global hasta haberse **usado y validado 3 veces** en
proyectos reales. La compuerta es lo que evita fabricar abstracciones especulativas.

```
descubrimiento → validación (3 usos) → extracción → promoción aquí → install → reutilización
```

## Definition of Done

Una tarea está cerrada solo si:

- cumple el objetivo pedido;
- preserva la consistencia del repo;
- no ha aumentado la complejidad innecesaria;
- no ha introducido conocimiento duplicado;
- la documentación afectada está actualizada.

## Qué NO hacer

- Duplicar conocimiento (copiar reglas dentro de skills en vez de referenciarlas).
- Crear documentos sin propietario claro.
- Optimizar para escenarios hipotéticos futuros.
- Introducir abstracciones antes de que las validen skills reales.
- Crear jerarquías o herencia entre skills (anti-patrón: las skills son planas y se
  componen por referencia, no por extensión).
- Saturar las reglas: pocas y afiladas. Demasiados ALWAYS/NEVER y ninguno aterriza.

## Autoridad

Este documento gobierna el repositorio.
`skills/skill-development-framework/` gobierna cómo se diseñan las skills.
Si ambos parecen solaparse, la metodología de diseño vive en el framework, no aquí.
