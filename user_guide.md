# User Guide

Esta es la puerta de entrada. No intenta explicarlo todo: apunta a la guía
correcta según lo que necesites.

## Si Estás Instalando Una Máquina Nueva

Lee:

- [Instalación de máquina para Windows](docs/guides/bootstrap-windows.md)

Esta guía está escrita para una persona no técnica. Explica cómo descargar el
repo, abrir PowerShell en la carpeta correcta, copiar el comando y comprobar que
Antigravity ve las skills.

Si el bootstrap falla y vas a pedir ayuda a un LLM, abre también:

- [Depuración del bootstrap para LLM](docs/guides/bootstrap-debug-llm.md)

Esa guía describe el contrato técnico: qué debía instalarse, qué rutas toca el
bootstrap, qué comandos ejecuta y cómo diagnosticar fallos de PATH, GitHub,
`uv`, `npm`, CLIs LLM, Poppler o Antigravity.

## Si Ya Instalaste La Máquina

Lee:

- [Mapa de uso del repositorio](docs/guides/repository-map.md)

Ahí se explica qué son `install.ps1`, `install.sh`, `/cierre`, `rules/`,
`skills/`, `workflows/`, `ci-templates/`, `project-bootstrap`,
`project-guardrails-audit` e `INDEX.json`.

## Camino Feliz En Una Línea

```text
Instalar Antigravity -> descargar biblio_skills -> ejecutar bootstrap-machine -> trabajar por chat
```

Después de instalar, lo normal es no tocar archivos manualmente. Pide cosas en
chat, por ejemplo:

```text
Voy a empezar un proyecto nuevo. Usa project-bootstrap.
```

```text
Este repo ha crecido; audita qué guardrails le faltan.
```

```text
Guarda esta decisión en memoria portable.
```

## Guías Disponibles

| Guía | Para qué sirve |
| --- | --- |
| [Instalación de máquina para Windows](docs/guides/bootstrap-windows.md) | Primer día en un PC con Antigravity recién instalado. |
| [Depuración del bootstrap para LLM](docs/guides/bootstrap-debug-llm.md) | Darle contexto técnico a un LLM cuando la instalación falla. |
| [Mapa de uso del repositorio](docs/guides/repository-map.md) | Entender qué pieza del repo usar en cada situación. |
