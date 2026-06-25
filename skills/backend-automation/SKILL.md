---
name: backend-automation
maturity: experimental
description: Crea y ejecuta scripts de automatización backend de calidad de producción (scraping, outreach, ETL, enriquecimiento de datos, tareas programadas) con documentación TASK.md y un índice maestro. Úsala SIEMPRE que el usuario pida "automatiza", "script para", "scrapea", "envía emails", "procesa este CSV", "tarea recurrente", o ejecutar/crear una automatización. Antes de escribir un script nuevo, comprueba si ya existe uno que lo haga.
---

# Backend Automation

Gestiona una biblioteca de automatizaciones donde cada tarea es una pieza de
ingeniería con su documentación de uso. Cuando se pide ejecutar una tarea: si el
script existe, se ejecuta; si no, se crea (documentado) y luego se ejecuta.

Los estándares de calidad (logging, manejo de errores, testing, seguridad, gestión
de secretos y dependencias) NO se repiten aquí: aplican las `rules/` universales.
Esta skill añade la **convención de organización y el ciclo de ejecución**.

## Estructura del repositorio de automatizaciones

```
automatizaciones/
├── RESUME.md               # índice maestro de todas las tareas (siempre al día)
├── .env / .env.example
├── .gitignore
└── scripts/
    └── <categoria>/<tarea>/
        ├── TASK.md          # documentación de uso (obligatorio)
        ├── main.py          # entrypoint
        ├── requirements.txt  # versiones fijadas
        └── tests/
```

## Ciclo de ejecución de una tarea

1. **Lee `RESUME.md`** para saber qué existe y no duplicar.
2. **Identifica el script** correcto y consulta su `TASK.md`.
3. **Verifica prerequisitos**: variables en `.env`, dependencias instaladas, ficheros
   de entrada presentes.
4. **Si falta algo, informa antes de ejecutar** — no ejecutes con datos incompletos.
5. **Muestra el comando exacto** antes de ejecutarlo.
6. **Reporta el resultado**: procesados / guardados / errores, ruta de salida, y causa
   raíz + corrección concreta si hubo fallo.
7. **Si el script no existe**: avísalo, créalo según las reglas, crea su `TASK.md`,
   actualiza `RESUME.md`, verifica prerequisitos y ejecuta.

## Carga de configuración (patrón correcto)

El helper de variables de entorno **lanza excepción**, no hace `print`+`sys.exit`
(coherente con la regla de logging estructurado y testeable):

```python
import os
from pathlib import Path
from dotenv import load_dotenv

load_dotenv(Path(__file__).parent / ".env")

def get_env_var(name: str, default: str | None = None) -> str:
    """Devuelve una variable de entorno requerida o lanza EnvironmentError."""
    value = os.getenv(name, default)
    if value is None:
        raise EnvironmentError(f"Variable de entorno requerida no encontrada: '{name}'. Añádela a .env")
    return value
```

> Nota: la versión original de este patrón usaba `print(...)` + `sys.exit(1)`, lo que
> (a) violaba la regla de "nunca print salvo CLI" y (b) hacía que un test que espera
> `pytest.raises(EnvironmentError)` fallara. Corregido a `raise`.

## Recursos

- `templates/TASK.md` — plantilla de documentación de tarea.
- `templates/RESUME.md` — plantilla del índice maestro.
