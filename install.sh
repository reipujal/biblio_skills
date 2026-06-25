#!/usr/bin/env bash
# install.sh — enlaza los activos de biblio_skills a las rutas globales de Antigravity.
# Uso:
#   ./install.sh                     # instala (symlinks)
#   ./install.sh --dry-run           # muestra qué haría, sin tocar nada
#   ./install.sh --project <ruta>    # además, enlaza workflows en <ruta>/.agents/workflows
#
# biblio_skills es la fuente de verdad: crea enlaces, no copias. Sin eval. Solo reemplaza
# destinos que son symlinks (los nuestros); si un destino es un fichero/carpeta real, ABORTA
# ese enlace en vez de borrarlo. Workflows: NO hay ruta global en Antigravity (verificado);
# solo se instalan por proyecto con --project.
set -euo pipefail

DRY_RUN=0
PROJECT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --project) PROJECT="${2:?--project requiere una ruta}"; shift 2 ;;
    *) echo "Argumento desconocido: $1" >&2; exit 2 ;;
  esac
done

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DST="${HOME}/.gemini/antigravity/skills"   # confirmado empíricamente (ping-test)

# Ficheros globales donde se escribe el bloque de reglas gestionado.
# biblio_skills/rules/ es la ÚNICA fuente de verdad; esto solo propaga.
GLOBAL_RULE_TARGETS=(
  "${HOME}/.gemini/GEMINI.md"        # Antigravity (y Gemini CLI mientras exista)
  # "${HOME}/.claude/CLAUDE.md"      # Claude Code (descomenta si lo usas global)
  # "${HOME}/.codex/AGENTS.md"       # Codex CLI (descomenta si lo usas global)
)

link() {  # link <origen> <destino> ; reemplaza solo si el destino es un symlink nuestro
  local src="$1" dst="$2"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  [dry-run] ln -s -- \"$src\" \"$dst\""
    return 0
  fi
  mkdir -p -- "$(dirname -- "$dst")"
  if [[ -L "$dst" ]]; then
    rm -- "$dst"                     # symlink existente: seguro de reemplazar
  elif [[ -e "$dst" ]]; then
    echo "  ✗ ABORTA: '$dst' existe y NO es un symlink — no lo toco. Resuélvelo a mano." >&2
    return 1
  fi
  ln -s -- "$src" "$dst"
  echo "  ✓ $dst -> $src"
}

echo "biblio_skills install (repo: $REPO)"
[[ "$DRY_RUN" -eq 1 ]] && echo "MODO DRY-RUN: no se toca nada."

echo
echo "1) Skills -> $SKILLS_DST"
for d in "$REPO"/skills/*/; do
  [[ -d "$d" ]] || continue
  link "${d%/}" "$SKILLS_DST/$(basename "$d")" || true
done

echo
echo "2) Reglas -> ficheros globales"
# Preferido: referenciar con @import absoluto. Si tu Antigravity no lo resuelve desde el
# fichero global, cambia REFERENCE=0 para concatenar el contenido.
REFERENCE=1
BEGIN="# >>> biblio_skills:rules (gestionado por install.sh) >>>"
END="# <<< biblio_skills:rules <<<"

build_block() {
  echo "$BEGIN"
  for f in "$REPO"/rules/*.md; do
    [[ "$(basename "$f")" == "00-index.md" ]] && continue
    if [[ "$REFERENCE" -eq 1 ]]; then echo "@$f"; else echo; cat "$f"; fi
  done
  echo "$END"
}

write_block() {  # write_block <fichero_global>
  local target="$1"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  [dry-run] actualizaria el bloque biblio_skills:rules en $target"; return 0
  fi
  mkdir -p -- "$(dirname -- "$target")"
  touch -- "$target"
  local tmp; tmp="$(mktemp)"
  awk -v b="$BEGIN" -v e="$END" '$0==b{skip=1} skip&&$0==e{skip=0;next} !skip{print}' "$target" > "$tmp"
  { cat "$tmp"; echo; build_block; } > "$target"
  rm -f -- "$tmp"
  echo "  ✓ bloque biblio_skills:rules actualizado en $target"
}

for target in "${GLOBAL_RULE_TARGETS[@]}"; do write_block "$target"; done
[[ "$DRY_RUN" -eq 1 ]] && { echo "  [dry-run] contenido del bloque:"; build_block | sed 's/^/      /'; }

echo
echo "3) Workflows (workspace-only; NO hay ruta global en Antigravity)"
if [[ -n "$PROJECT" ]]; then
  wf_dst="$PROJECT/.agents/workflows"
  echo "   -> $wf_dst"
  for f in "$REPO"/workflows/*.md; do
    [[ -e "$f" ]] || continue
    link "$f" "$wf_dst/$(basename "$f")" || true
  done
else
  echo "   omitidos (usa --project <ruta_repo> para instalar /cierre en .agents/workflows)."
fi

echo
echo "Hecho. biblio_skills/rules/ y skills/ son la única fuente: edita ahí y reejecuta."
