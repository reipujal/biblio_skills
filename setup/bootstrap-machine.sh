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
NPM_TOOLS=("@openai/codex:codex" "@google/gemini-cli:gemini")
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
for t in git gh uv npm; do
  if ! command -v "$t" >/dev/null 2>&1; then
    echo "ERROR: falta $t."
    case "$t" in
      git) echo "  Instálalo con tu gestor del sistema (apt/brew/etc.)." ;;
      gh)  echo "  Instálalo: https://cli.github.com/" ;;
      uv)  echo "  Instálalo: https://docs.astral.sh/uv/getting-started/installation/" ;;
      npm) echo "  Instala Node.js LTS con tu gestor del sistema." ;;
    esac
    exit 1
  fi
done
echo "git: $(git --version)"
echo "gh: $(gh --version | head -n 1)"
echo "uv: $(uv --version)"
echo "npm: $(npm --version)"

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

# 5. CLIs LLM.
echo "== Instalando/verificando CLIs LLM =="
for spec in "${NPM_TOOLS[@]}"; do
  package="${spec%%:*}"
  command_name="${spec##*:}"
  if command -v "$command_name" >/dev/null 2>&1; then
    echo "  OK: $command_name"
  else
    npm install -g "$package"
  fi
done

if command -v claude >/dev/null 2>&1; then
  echo "  OK: claude"
else
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL https://claude.ai/install.sh | bash
  else
    echo "ERROR: falta curl para instalar Claude Code."
    exit 1
  fi
fi

for t in codex gemini claude; do
  if ! command -v "$t" >/dev/null 2>&1; then
    echo "ERROR: $t se ha instalado o intentado instalar, pero no aparece en PATH."
    echo "  Abre una terminal nueva y reejecuta el bootstrap."
    exit 1
  fi
done
echo "CLIs LLM listas: codex gemini claude"

# 6. Herramientas de SISTEMA que uv NO puede instalar — verificar, no instalar
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

# 7. Conectar biblio_skills con Antigravity.
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
