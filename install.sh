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
GEMINI_MD="${HOME}/.gemini/GEMINI.md"

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
echo "3) Reglas -> $GEMINI_MD"
# Estrategia preferida: referenciar con @import absoluto (un solo bloque gestionado).
# Si tu version de Antigravity no resuelve @import absoluto desde el GEMINI.md global,
# cambia REFERENCE=0 para concatenar el contenido en su lugar.
REFERENCE=1
BEGIN="# >>> biblio_skills:rules (gestionado por install.sh) >>>"
END="# <<< biblio_skills:rules <<<"

build_block() {
  echo "$BEGIN"
  if [[ "$REFERENCE" -eq 1 ]]; then
    for f in "$REPO"/rules/*.md; do
      [[ "$(basename "$f")" == "00-index.md" ]] && continue
      echo "@$f"
    done
  else
    for f in "$REPO"/rules/*.md; do
      [[ "$(basename "$f")" == "00-index.md" ]] && continue
      echo; cat "$f"
    done
  fi
  echo "$END"
}

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "  [dry-run] actualizaria el bloque biblio_skills:rules en $GEMINI_MD :"
  build_block | sed 's/^/      /'
else
  mkdir -p "$(dirname "$GEMINI_MD")"
  touch "$GEMINI_MD"
  # elimina un bloque previo gestionado por este script (idempotente)
  tmp="$(mktemp)"
  awk -v b="$BEGIN" -v e="$END" '
    $0==b {skip=1} skip && $0==e {skip=0; next} !skip {print}
  ' "$GEMINI_MD" > "$tmp"
  { cat "$tmp"; echo; build_block; } > "$GEMINI_MD"
  rm -f "$tmp"
  echo "  ✓ bloque biblio_skills:rules actualizado en $GEMINI_MD"
fi

echo
echo "Hecho. Verifica en Antigravity que las skills aparecen y que una regla del"
echo "bloque se respeta. Si el @import no resuelve, reinstala con REFERENCE=0 en el script."
