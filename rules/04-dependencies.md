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

**Reproducibilidad / recuperación en otra máquina.** Distingue dos ámbitos:
- *Toolchain global (por máquina, NO por proyecto):* versión de Python, CLIs de calidad
  (pre-commit, ruff, detect-secrets) y herramientas de sistema (poppler). Se instala una
  vez con `setup/bootstrap-machine.sh`. Un `requirements.lock` global es un anti-patrón:
  rompe el aislamiento y provoca conflictos de versión entre proyectos.
- *Dependencias del proyecto (por repo):* `requirements.in` (directas, flexibles) →
  `uv pip compile requirements.in -o requirements.lock` (árbol completo clavado, va en git)
  → `uv pip sync requirements.lock`. El lock es lo reproducible. Los pasos de restauración
  (incl. instalables no-pip) se declaran en la sección "Comandos" del `AGENTS.md` del repo.

[CI] La coherencia "lo importado está declarado / lo declarado está instalado" es
comprobable y se enforca en pre-commit (ver `ci-templates/`).
