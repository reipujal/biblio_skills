#!/usr/bin/env python3
"""build_index.py — genera/valida INDEX.json escaneando skills/*/SKILL.md.

  python scripts/build_index.py            # (re)genera INDEX.json
  python scripts/build_index.py --check     # NO escribe; falla (exit 1) si hay problemas
                                            # o si INDEX.json está desactualizado (drift)

El catálogo lo consulta skill-finder; no debe aceptar definiciones incompletas en silencio.
Sin dependencias externas: parser mínimo del frontmatter YAML.
"""
import json
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SKILLS = REPO / "skills"
OUT = REPO / "INDEX.json"
VALID_MATURITY = {"experimental", "beta", "validated"}


def parse_frontmatter(md_path: Path) -> dict:
    text = md_path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    data, key = {}, None
    for line in text[3:end].splitlines():
        if line[:1].isspace() and key:
            data[key] += " " + line.strip()
            continue
        if ":" in line:
            k, _, v = line.partition(":")
            k, v = k.strip(), v.strip().strip('"').strip("'")
            if k in ("name", "description", "maturity"):
                data[k] = v
                key = k
            else:
                key = None
    return data


def collect():
    """Devuelve (entries, problems)."""
    entries, problems, seen = [], [], {}
    for skill_dir in sorted(p for p in SKILLS.iterdir() if p.is_dir()):
        sm = skill_dir / "SKILL.md"
        if not sm.exists():
            problems.append(f"{skill_dir.name}: falta SKILL.md")
            continue
        fm = parse_frontmatter(sm)
        name = fm.get("name", "")
        desc = fm.get("description", "")
        mat = fm.get("maturity", "")
        if not name:
            problems.append(f"{skill_dir.name}: falta 'name' en frontmatter")
            name = skill_dir.name
        if name != skill_dir.name:
            problems.append(f"{skill_dir.name}: 'name' ({name}) != nombre de carpeta")
        if not desc:
            problems.append(f"{skill_dir.name}: falta 'description'")
        if mat and mat not in VALID_MATURITY:
            problems.append(f"{skill_dir.name}: maturity '{mat}' no válida {sorted(VALID_MATURITY)}")
        if name in seen:
            problems.append(f"nombre duplicado: {name}")
        seen[name] = True
        entries.append({
            "name": name,
            "description": desc,
            "maturity": mat or "unspecified",
            "path": f"skills/{skill_dir.name}",
        })
    return entries, problems


def catalog_obj(entries):
    return {
        "version": 1,
        "note": "Catálogo de la biblioteca. Generado por scripts/build_index.py — no editar a mano.",
        "count": len(entries),
        "skills": entries,
    }


def main(argv) -> int:
    if not SKILLS.is_dir():
        print(f"No existe {SKILLS}", file=sys.stderr)
        return 1
    check = "--check" in argv
    entries, problems = collect()
    new = catalog_obj(entries)

    if check:
        if problems:
            print("PROBLEMAS en las skills:", file=sys.stderr)
            for p in problems:
                print(f"  - {p}", file=sys.stderr)
        drift = True
        if OUT.exists():
            try:
                drift = json.loads(OUT.read_text(encoding="utf-8")) != new
            except json.JSONDecodeError:
                drift = True
        if drift:
            print("INDEX.json está desactualizado: ejecuta build_index.py para regenerarlo.", file=sys.stderr)
        if problems or drift:
            return 1
        print(f"--check OK: {len(entries)} skills, INDEX.json al día.")
        return 0

    if problems:
        print("Aviso (se genera igualmente, corrige estos puntos):", file=sys.stderr)
        for p in problems:
            print(f"  - {p}", file=sys.stderr)
    OUT.write_text(json.dumps(new, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"INDEX.json escrito con {len(entries)} skills.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
