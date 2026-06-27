#!/usr/bin/env bash
# bootstrap-machine.sh — prepara una máquina Unix/WSL para vivir en Antigravity con biblio_skills.
#
# Qué hace y qué NO hace:
#   - SÍ: verifica base del sistema, fija Python, instala CLIs globales aisladas,
#         verifica herramientas externas y conecta biblio_skills con Antigravity.
#   - NO: instalar dependencias de proyecto. Esas viven en cada repo (requirements.lock),
#         por aislamiento y reproducibilidad. Un lock global sería un anti-patrón.
set -euo pipefail

PYTHON_VERSION="3.14"          # uv resuelve al último patch (3.14.x)
GLOBAL_TOOLS=(pre-commit detect-secrets ruff)
PROJECT=""
SKIP_INSTALL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT="${2:?--project requiere una ruta}"; shift 2 ;;
    --skip-install) SKIP_INSTALL=1; shift ;;
    *) echo "Argumento desconocido: $1" >&2; exit 2 ;;
  esac
done

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "== biblio_skills :: bootstrap de máquina =="
echo "repo: $REPO"

# 1. Base del sistema.
for t in git gh uv; do
  if ! command -v "$t" >/dev/null 2>&1; then
    echo "ERROR: falta $t."
    case "$t" in
      git) echo "  Instálalo con tu gestor del sistema (apt/brew/etc.)." ;;
      gh)  echo "  Instálalo: https://cli.github.com/" ;;
      uv)  echo "  Instálalo: https://docs.astral.sh/uv/getting-started/installation/" ;;
    esac
    exit 1
  fi
done
echo "git: $(git --version)"
echo "gh: $(gh --version | head -n 1)"
echo "uv: $(uv --version)"

if ! gh auth status >/dev/null 2>&1; then
  echo "ERROR: GitHub CLI no está autenticado."
  echo "  Ejecuta: gh auth login"
  exit 1
fi
echo "GitHub CLI autenticado."

# 2. uv presente (es el gestor del toolchain Python)
if ! command -v uv >/dev/null 2>&1; then
  echo "ERROR: uv no está instalado."
  echo "  Instálalo: https://docs.astral.sh/uv/getting-started/installation/"
  exit 1
fi

# 3. Python objetivo, gestionado por uv (no toca el Python del sistema)
uv python install "$PYTHON_VERSION"
echo "Python $PYTHON_VERSION gestionado por uv."

# 4. CLIs globales — cada una en su propio entorno aislado (no contaminan proyectos)
for tool in "${GLOBAL_TOOLS[@]}"; do
  uv tool install --upgrade "$tool"
done
echo "Herramientas globales instaladas: ${GLOBAL_TOOLS[*]}"

# 5. Herramientas de SISTEMA que uv NO puede instalar — verificar, no instalar
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
  exit 1
fi

# 6. Conectar biblio_skills con Antigravity.
if [[ "$SKIP_INSTALL" -eq 1 ]]; then
  echo "Instalación de biblio_skills omitida por --skip-install."
else
  args=()
  if [[ -n "$PROJECT" ]]; then args+=(--project "$PROJECT"); fi
  "$REPO/install.sh" "${args[@]}"
fi

echo
echo "== Hecho. Toolchain global y Antigravity listos. =="
echo "Dependencias de cada proyecto: 'uv pip compile requirements.in -o requirements.lock'"
echo "(ver la skill project-bootstrap)."
