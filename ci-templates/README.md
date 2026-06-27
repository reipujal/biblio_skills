# ci-templates — Catálogo de Guardrails

Este directorio no es un repositorio de "copia y pega todo". Es un **catálogo de guardrails automáticos identificados**, cada uno con una CONDICIÓN estricta de aplicación. Su objetivo es delimitar qué se controla y cuándo aplica.

Las plantillas aquí refuerzan lo determinista (lo que una máquina puede comprobar). Mientras que `rules/` define el estándar y el criterio de trabajo (ej. manejo de secretos, reproducibilidad; ver `../rules/04-dependencies.md`), las `ci-templates` son las barreras duras que bloquean el error.

## Niveles de Aplicación

Existen dos niveles de guardrails:

1. **Baseline (siempre, en todo repo):** Se instalan sin preguntar porque son comprobaciones rápidas, baratas y universalmente útiles. Incluye:
   - `pre-commit` con hooks oficiales (whitespace, fin de fichero, validación YAML/JSON, ficheros grandes, marcadores de merge).
   - `detect-secrets` para prevenir el filtrado accidental de credenciales y tokens.
   - `check_encoding.py` propio para detectar problemas de encoding (UTF-8, mojibake), especialmente relevante para flujos en español.

2. **Condicional (solo si hay señal):** Se aplican *únicamente* cuando el proyecto presenta una señal detectable (ej. uso de Python, Node.js, presencia de tests).

## Catálogo de Guardrails

| Guardrail                     | Qué controla                              | Aplica si (señal)                                                             | Herramienta                                             | Estado en el catálogo                        |
| :---------------------------- | :---------------------------------------- | :---------------------------------------------------------------------------- | :------------------------------------------------------ | :------------------------------------------- |
| **pre-commit baseline**       | higiene + secretos + encoding             | siempre                                                                       | pre-commit-hooks + detect-secrets + check_encoding.py   | plantilla disponible                         |
| **GitHub Actions CI**         | ejecuta tests/checks en push/PR           | hay remote en GitHub **y** existe un comando de tests/checks REAL que pueda pasar | GitHub Actions                                          | plantilla disponible                         |
| **Lint/format Python**        | calidad y estilo de código Python         | hay `.py` / `pyproject.toml` / `requirements.in`                              | ruff                                                    | identificado (pendiente de hook pre-commit)  |
| **Lock de dependencias Python** | control de versiones y reproducibilidad   | hay `requirements.in`                                                         | uv pip compile                                          | cubierto por la [regla 04](../rules/04-dependencies.md) |
| **Lint/format web (JS/TS)**   | calidad y estilo de código JS/TS          | hay `package.json` o ficheros web                                             | prettier (+ eslint/biome si es Node)                    | identificado, sin plantilla aún              |
| **Lock de dependencias JS**   | control de versiones y reproducibilidad   | hay `package.json`                                                            | lock del gestor (npm/pnpm)                              | identificado, sin plantilla aún              |

*(Nota CI: un repositorio sin suite de pruebas, como `biblio_skills`, NO debe forzar una CI que asuma `pytest` por defecto, ya que quedaría roja siempre. El comando debe parametrizarse validando la realidad del proyecto, guiándose por el documento `AGENTS.md` de dicho repo).*

## Cómo se usa el catálogo

- La skill **`project-bootstrap`** copia e instala el baseline automáticamente al crear repositorios nuevos.
- La skill **`project-guardrails-audit`** evalúa las condiciones en repositorios existentes y reporta qué falta. Esto incluye alertar sobre riesgos para los cuales el catálogo actual aún no tiene una plantilla disponible (los reporta como un hueco a cubrir).

## Instalación Manual (Plantillas Disponibles)

Si necesitas instalar manualmente los guardrails de los que SÍ disponemos plantilla actualmente, ejecuta lo siguiente:

```bash
# Desde la raíz del proyecto destino:
cp <biblio_skills>/ci-templates/pre-commit-config.yaml .pre-commit-config.yaml
mkdir -p .github/workflows scripts
cp <biblio_skills>/ci-templates/github-actions-ci.yml .github/workflows/ci.yml
cp <biblio_skills>/ci-templates/check_encoding.py scripts/check_encoding.py

# Instalación de pre-commit y secretos como CLIs globales aisladas:
# si ya ejecutaste setup/bootstrap-machine.sh, este paso ya está hecho.
uv tool install pre-commit
uv tool install detect-secrets
pre-commit install                      # activa el hook local
detect-secrets scan > .secrets.baseline # baseline inicial de secretos
```

> **Aviso Importante:** Al copiar `github-actions-ci.yml`, debes **ajustar el comando de tests** al stack real del proyecto destino. Lee la sección de comandos del `AGENTS.md` de tu repositorio antes de configurar GitHub Actions; no hardcodees `pytest` si tu proyecto no cuenta con tests en ese framework.
