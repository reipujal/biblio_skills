---
name: project-guardrails-audit
maturity: experimental
description: Audita repositorios existentes contra el catálogo de `ci-templates/` para decidir qué guardrails automáticos aplicar, adaptar, mantener o descartar. Úsala cuando el usuario diga "revisa qué ci-templates debería tener este proyecto", "audita las barreras del proyecto", "qué checks automáticos me faltan", "este proyecto ha crecido, revisa CI/pre-commit", "qué guardrails necesita este repo", "revisa la higiene de CI", o "autorevísate e identifica qué de ci-templates aplica". Reporta también riesgos reales sin plantilla disponible en el catálogo.
---

# Project Guardrails Audit

Audita guardrails de un repositorio existente evaluándolos contra el catálogo definido en `ci-templates/README.md`. A diferencia de `project-bootstrap` (que arranca e instala el baseline en repositorios nuevos), ESTA skill se usa para auditar repositorios existentes o evolucionados. **No se debe usar para crear proyectos desde cero.**

## Principio Central

`ci-templates/` es un **catálogo con condiciones**, no un paquete a instalar por completo. La única fuente de verdad sobre estas condiciones es `ci-templates/README.md`. Esta skill NO mantiene su propia tabla de heurísticas ni reglas duplicadas; si las condiciones cambian, cambian únicamente en el catálogo para evitar divergencias. El juicio se ejerce en esta skill, pero la ejecución y el enforcement (bloqueo) recaen en la CI o en los hooks.

## Procedimiento

Para realizar una auditoría, sigue estrictamente estos pasos:

### A. Contexto
Inspecciona los ficheros existentes en el repositorio actual para comprender su naturaleza: `AGENTS.md`, `README.md`, `pyproject.toml`, `requirements.in`/`requirements.lock`, `package.json`, `Cargo.toml`, `go.mod`, directorios clave (`tests/`, `src/`, `scripts/`, `docs/`, `.github/workflows/`), `.pre-commit-config.yaml`, `.secrets.baseline`, `.env.example`, `.gitignore`, `Makefile`, y cualquier configuración de linters o formateadores.

### B. Tipo de proyecto
Determina el perfil del repositorio a partir de sus ficheros:
Python / JS-TS / docs-Markdown / automatización-ETL / librería / app-API / data / multi-lenguaje / experimental.

### C. Señales a detectar
Busca las condiciones que disparan los guardrails:
- Código versionado presente.
- Tests reales ejecutables (o la total ausencia de ellos).
- Repositorio remoto apuntando a GitHub.
- Configuración de Pull Requests o ramas protegidas.
- Ficheros de entorno (`.env.example`) o secretos potenciales.
- Uso de APIs, tokens, scraping o gestión de credenciales.
- Volumen significativo de ficheros Markdown o español que arriesgue mojibake.
- Artefactos generados que requieran ser ignorados (logs, outputs).
- Dependencias declaradas con o sin fichero de lock.
- Scripts de mantenimiento repetidos.
- Sistema de CI roto, incompleto o que falla perpetuamente.

### D. Cruzar contra el catálogo del README
Para **cada guardrail listado en `ci-templates/README.md`**, evalúa su condición "aplica si" contra las señales detectadas. Decide si el guardrail:
- Aplicar (falta y debería instalarse).
- Ya presente (verificado y en buen estado).
- Adaptar (existe un intento pero difiere de la plantilla o el stack).
- No aplica (condición no cumplida).
- Revisar (estado ambiguo, requiere supervisar a mano).

### E. Cobertura del catálogo (Clave)
Analiza si el proyecto presenta un **riesgo real para el que el catálogo NO tiene guardrail** (ni plantilla ni entrada identificada). En ese caso, delátalo y repórtalo explícitamente como "hueco del catálogo", describiendo el riesgo y proponiendo qué guardrail (o herramienta madura) debería adoptarse en el futuro para cubrirlo. Esto es vital para evolucionar la biblioteca `biblio_skills`.

## Salida Obligatoria (El Reporte)

Presenta tu auditoría estructurada mediante los siguientes apartados:

1. **Resumen ejecutivo**: Conclusión breve de la situación del repositorio.
2. **Tipo de proyecto**: El perfil identificado.
3. **Evidencia observada**: Listado de señales relevantes encontradas en paso C.
4. **Matriz de guardrails**: (Ver formato debajo).
5. **Huecos del catálogo**: Riesgos identificados que carecen de guardrail disponible en el catálogo base.
6. **Acciones recomendadas**: Qué instalar o corregir.
7. **Acciones que NO recomiendo**: Qué evitar (p. ej., no instalar CI si no hay tests).
8. **Preguntas abiertas**: Decisiones que requieren feedback del usuario.
9. **Siguiente paso seguro**: La primera acción clara que propones hacer si recibes el OK.

#### Formato Matriz
Usa una tabla con estas columnas: `Guardrail | Estado | Decisión | Motivo | Acción concreta`
- Estados: *presente*, *faltante*, *parcial*, *no evaluado*
- Decisiones: *aplicar*, *adaptar*, *mantener*, *no aplicar*, *revisar*

## Seguridad y Anti-Patrones

- **Por defecto audita y propone**: NO modifiques repositorios salvo petición explícita tras entregar el reporte.
- **Si el usuario pide aplicar (tras tu OK)**: Preserva lo existente. No sobrescribas configuraciones sin revisar a fondo, adapta los comandos (p. ej., de tests) al stack real del proyecto, ejecuta los checks justo después de la aplicación y explica claramente qué cambió.
- **Atención especial a la CI**: NO instales una GitHub Actions CI que asuma un comando de tests inexistente (provocarás un rojo perpetuo). Si no hay tests reales demostrables, repórtalo en tu documento, pero no lo fuerces.
- **Anti-patrones estrictos**:
  - NO copiar todo el catálogo por defecto.
  - NO instalar CI si la plataforma o la suite de ejecución difiere de la realidad del código.
  - NO crear checks automáticos que nadie pueda correr localmente con facilidad.
  - NO duplicar reglas en distintas configuraciones si una herramienta puede agruparlas.
  - NO sustituir los tests reales por puros linters.
  - NO tratar al modelo / CLI como verificación determinista (las máquinas lo hacen mejor).
  - NO sobrescribir configuraciones `.yml` con `>` a ciegas (es un gran riesgo estructural).
  - NO inventes ni dupliques la tabla heurística de condiciones dentro de este `SKILL.md`. ¡Esa tabla pertenece y vive únicamente en el `ci-templates/README.md`!

## Integración con otras Skills

- Utiliza `project-bootstrap` si resulta ser un repositorio completamente vacío fundado desde cero.
- Utiliza `skill-development-framework` si el hueco detectado evidencia un patrón reusable que amerita una nueva plantilla CI.
- Utiliza `memory-keeper` si se toma una decisión consciente (p. ej., excluir un guardrail permanentemente) y hay que documentarla para futuros agentes.
- Utiliza `audit-board` si el repositorio evidencia riesgos estructurales serios, manejo descuidado de capital/producción y requiere una revisión masiva cruzada.
