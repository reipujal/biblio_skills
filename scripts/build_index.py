#!/usr/bin/env python3
"""build_index.py — regenera INDEX.json escaneando skills/*/SKILL.md.

El catálogo es la fuente que consulta skill-finder. Se regenera, no se edita a mano
(así no queda desactualizado). Ejecutar tras crear/editar/borrar una skill:

    python scripts/build_index.py

Sin dependencias externas: parser mínimo del frontmatter YAML (name + description).
"""
import json
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SKILLS = REPO / "skills"
OUT = REPO / "INDEX.json"


def parse_frontmatter(md_path: Path) -> dict:
    """Extrae name y description del frontmatter YAML (--- ... ---)."""
    text = md_path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    block = text[3:end]
    data: dict[str, str] = {}
    key = None
    for line in block.splitlines():
        if line[:1].isspace() and key:  # continuación de un valor multilinea
            data[key] += " " + line.strip()
            continue
        if ":" in line:
            k, _, v = line.partition(":")
            k = k.strip()
            v = v.strip().strip('"').strip("'")
            if k in ("name", "description"):
                data[k] = v
                key = k
            else:
                key = None
    return data


def main() -> int:
    if not SKILLS.is_dir():
        print(f"No existe {SKILLS}", file=sys.stderr)
        return 1
    entries = []
    for skill_dir in sorted(p for p in SKILLS.iterdir() if p.is_dir()):
        sm = skill_dir / "SKILL.md"
        if not sm.exists():
            continue
        fm = parse_frontmatter(sm)
        entries.append({
            "name": fm.get("name", skill_dir.name),
            "description": fm.get("description", ""),
            "path": f"skills/{skill_dir.name}",
        })
    catalog = {
        "version": 1,
        "note": "Catálogo de la biblioteca. Generado por scripts/build_index.py — no editar a mano.",
        "count": len(entries),
        "skills": entries,
    }
    OUT.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"INDEX.json escrito con {len(entries)} skills.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
