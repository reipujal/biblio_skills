# [Nombre de la Tarea]

## Descripción
Qué hace este script en 2-3 oraciones.

## Casos de uso
- "[ejemplo concreto de cuándo ejecutarlo]"

## Configuración necesaria
Variables de entorno (en `.env`):
- `API_KEY` — [propósito]

Ficheros de entrada:
- `input/datos.csv` — columnas: `...`

## Cómo ejecutar
```bash
python main.py --query "..." --limit 100 --output output/out.csv
```

## Argumentos
| Parámetro | Tipo | Requerido | Default | Descripción |
|-----------|------|-----------|---------|-------------|
| `--query` | str | Sí | - | ... |
| `--limit` | int | No | 100 | ... |

## Output esperado
- Fichero en `output/...` con columnas `...`
- Resumen en consola: procesados / guardados / errores.

## Errores comunes
| Error | Causa | Solución |
|-------|-------|----------|
| `EnvironmentError: API_KEY...` | falta en `.env` | añadirla |
| `ModuleNotFoundError` | dependencia no instalada | `pip install -r requirements.txt` |

## Notas
- Idempotente: misma entrada dos veces no duplica datos.
- Salida con timestamp para evitar sobreescrituras.
