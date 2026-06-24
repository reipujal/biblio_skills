#!/usr/bin/env bash
# bootstrap-machine.sh — configura el toolchain GLOBAL de la máquina (una vez por PC).
#
# Qué hace y qué NO hace:
#   - SÍ: fija la versión de Python, instala las CLIs globales aisladas, verifica las
#         herramientas de sistema. Esto es "recuperar la configuración en otro PC".
#   - NO: instalar dependencias de proyecto. Esas viven en cada repo (requirements.lock),
#         por aislamiento y reproducibilidad. Un lock global sería un anti-patrón.
set -euo pipefail

PYTHON_VERSION="3.14"          # uv resuelve al último patch (3.14.x)
GLOBAL_TOOLS=(pre-commit detect-secrets ruff)

echo "== biblio_skills :: bootstrap de máquina =="

# 1. uv presente (es el gestor; no lo instalamos desde aquí para no asumir el método)
if ! command -v uv >/dev/null 2>&1; then
  echo "ERROR: uv no está instalado."
  echo "  Instálalo: https://docs.astral.sh/uv/getting-started/installation/"
  exit 1
fi
echo "uv: $(uv --version)"

# 2. Python objetivo, gestionado por uv (no toca el Python del sistema)
uv python install "$PYTHON_VERSION"
echo "Python $PYTHON_VERSION gestionado por uv."

# 3. CLIs globales — cada una en su propio entorno aislado (no contaminan proyectos)
for tool in "${GLOBAL_TOOLS[@]}"; do
  uv tool install --upgrade "$tool"
done
echo "Herramientas globales instaladas: ${GLOBAL_TOOLS[*]}"

# 4. Herramientas de SISTEMA que uv NO puede instalar — verificar, no instalar
echo "== Comprobando herramientas de sistema (poppler-utils) =="
missing=()
for t in pdfinfo pdftotext pdffonts pdftoppm; do
  if command -v "$t" >/dev/null 2>&1; then
    echo "  OK: $t"
  else
    echo "  FALTA: $t"
    missing+=("$t")
  fi
done
if (( ${#missing[@]} > 0 )); then
  echo "  Faltan binarios de poppler-utils. Según tu SO:"
  echo "    WSL / Debian-Ubuntu : sudo apt install poppler-utils"
  echo "    Windows (scoop)     : scoop install poppler"
  echo "    Windows (choco)     : choco install poppler"
  echo "    macOS (brew)        : brew install poppler"
fi

echo
echo "== Hecho. Toolchain global listo. =="
echo "Dependencias de cada proyecto: 'uv pip compile requirements.in -o requirements.lock'"
echo "(ver la skill project-bootstrap)."
