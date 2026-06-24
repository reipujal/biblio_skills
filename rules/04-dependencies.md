# Dependencias

- Todo `requirements.txt` usa **versiones fijadas** (`requests==2.31.0`), nunca rangos
  abiertos ni sin versión.
- Al instalar un paquete nuevo, actualiza `requirements.txt` en el acto, con un
  comentario que indique su propósito. Si es dependencia de infra/desarrollo (no de
  negocio), va en una sección separada.
- No inventes dependencias: antes de un `import`, verifica que la librería existe y
  está declarada. Nunca asumas que está disponible sin comprobarlo.
- Objetivo: que `pip install -r requirements.txt` reconstruya el entorno completo sin
  dependencias fantasma.

**Reproducibilidad / recuperación en otra máquina.** Cada proyecto mantiene:
- `requirements.txt` — directas, con versión fijada y comentario de propósito.
- `requirements.lock` — árbol completo congelado (`pip freeze`, o `uv`/`pip-tools`).
- Los comandos de restauración del entorno declarados en la sección "Comandos" del
  `AGENTS.md` del proyecto (clonar → crear venv → instalar lock → variables `.env`).
  No solo paquetes pip: cualquier instalable o paso manual (servicios, claves, binarios)
  va documentado ahí, de modo que montar el proyecto en un PC nuevo sea determinista.

[CI] La coherencia "lo importado está declarado / lo declarado está instalado" es
comprobable y se enforca en pre-commit (ver `ci-templates/`).
