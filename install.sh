#!/usr/bin/env bash
# install.sh — enlaza los activos de biblio_skills a las rutas globales de Antigravity.
# Uso:
#   ./install.sh            # instala (symlinks)
#   ./install.sh --dry-run  # muestra qué haría, sin tocar nada
#
# biblio_skills es la fuente de verdad: este script crea enlaces, no copias, para que
# un git pull actualice todo. Las ci-templates NO se instalan globalmente (se copian
# por proyecto; ver ci-templates/README.md).
set -euo pipefail

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DST="${HOME}/.gemini/config/skills"
WORKFLOWS_DST="${HOME}/.gemini/antigravity/global_workflows"

# Ficheros globales donde se escribe el bloque de reglas gestionado.
# biblio_skills/rules/ es la ÚNICA fuente de verdad; esto solo propaga.
# Descomenta los harnesses que uses globalmente para que NO diverjan:
GLOBAL_RULE_TARGETS=(
  "${HOME}/.gemini/GEMINI.md"        # Antigravity (y Gemini CLI mientras exista)
  # "${HOME}/.claude/CLAUDE.md"      # Claude Code (descomenta si lo usas global)
  # "${HOME}/.codex/AGENTS.md"       # Codex CLI (descomenta si lo usas global)
)

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  [dry-run] $*"
  else
    eval "$@"
  fi
}

link() {  # link <origen> <destino>
  local src="$1" dst="$2"
  run "mkdir -p \"$(dirname "$dst")\""
  if [[ -e "$dst" || -L "$dst" ]]; then
    run "rm -rf \"$dst\""
  fi
  run "ln -s \"$src\" \"$dst\""
  echo "  ✓ $dst -> $src"
}

echo "biblio_skills install (repo: $REPO)"
[[ "$DRY_RUN" -eq 1 ]] && echo "MODO DRY-RUN: no se toca nada."

echo
echo "1) Skills -> $SKILLS_DST"
for d in "$REPO"/skills/*/; do
  [[ -d "$d" ]] || continue
  name="$(basename "$d")"
  link "${d%/}" "$SKILLS_DST/$name"
done

echo
echo "2) Workflows -> $WORKFLOWS_DST"
for f in "$REPO"/workflows/*.md; do
  [[ -e "$f" ]] || continue
  name="$(basename "$f")"
  link "$f" "$WORKFLOWS_DST/$name"
done

echo
echo "3) Reglas -> ficheros globales"
# Estrategia preferida: referenciar con @import absoluto (un solo bloque gestionado).
# Si tu version de Antigravity no resuelve @import absoluto desde el fichero global,
# cambia REFERENCE=0 para concatenar el contenido en su lugar.
REFERENCE=1
BEGIN="# >>> biblio_skills:rules (gestionado por install.sh) >>>"
END="# <<< biblio_skills:rules <<<"

build_block() {
  echo "$BEGIN"
  for f in "$REPO"/rules/*.md; do
    [[ "$(basename "$f")" == "00-index.md" ]] && continue
    if [[ "$REFERENCE" -eq 1 ]]; then
      echo "@$f"
    else
      echo; cat "$f"
    fi
  done
  echo "$END"
}

write_block() {  # write_block <fichero_global>
  local target="$1"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  [dry-run] actualizaria el bloque biblio_skills:rules en $target"
    return
  fi
  run "mkdir -p \"$(dirname "$target")\""
  touch "$target"
  local tmp; tmp="$(mktemp)"
  # elimina un bloque previo gestionado por este script (idempotente)
  awk -v b="$BEGIN" -v e="$END" '
    $0==b {skip=1} skip && $0==e {skip=0; next} !skip {print}
  ' "$target" > "$tmp"
  { cat "$tmp"; echo; build_block; } > "$target"
  rm -f "$tmp"
  echo "  ✓ bloque biblio_skills:rules actualizado en $target"
}

for target in "${GLOBAL_RULE_TARGETS[@]}"; do
  write_block "$target"
done

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "  [dry-run] contenido del bloque:"; build_block | sed 's/^/      /'
fi

echo
echo "Hecho. Verifica en Antigravity que las skills aparecen y que una regla del"
echo "bloque se respeta. Si el @import no resuelve, reinstala con REFERENCE=0 en el script."
echo "biblio_skills/rules/ es la unica fuente: edita ahi y reejecuta install.sh para"
echo "propagar a todos los GLOBAL_RULE_TARGETS sin que diverjan."
