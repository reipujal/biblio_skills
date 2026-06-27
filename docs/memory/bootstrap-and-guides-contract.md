---
name: bootstrap-and-guides-contract
description: Contrato de bootstrap y guías: instalación no técnica, depuración LLM y separación mantenimiento/install
metadata:
  type: project
---

`biblio_skills` debe explicar la instalación y el uso con guías separadas por audiencia:

- `docs/guides/bootstrap-windows.md`: guía paso a paso para una persona no técnica en Windows.
- `docs/guides/bootstrap-debug-llm.md`: contrato técnico para que un LLM depure fallos del bootstrap.
- `docs/guides/repository-map.md`: mapa práctico del repo (`install.ps1`, `/cierre`, `rules`, `skills`, `workflows`, `ci-templates`, memoria, `INDEX.json`).
- `user_guide.md`: índice corto que apunta a esas guías, no manual largo.
- `README.md`: brújula conceptual y enlaces, no duplicación de instrucciones detalladas.

El contrato operativo del bootstrap es: instalar Antigravity primero, descargar/clonar `biblio_skills`, ejecutar `setup/bootstrap-machine.*`, y desde ahí trabajar por chat. El bootstrap prepara el toolchain global, instala/verifica CLIs LLM auxiliares (`codex`, `claude`, `gemini`) y conecta `biblio_skills` con Antigravity. No instala Antigravity ni dependencias de proyectos concretos.

`install.ps1` / `install.sh` son conexión/refresco de una biblioteca ya preparada: enlazan skills, propagan rules e instalan workflows por proyecto. No deben regenerar `INDEX.json` ni modificar archivos versionados durante una instalación normal. Regenerar `INDEX.json` con `scripts/build_index.py` es mantenimiento de la biblioteca antes de commitear cambios de skills/frontmatter.

Antes de compactar una conversación larga, guardar primero las decisiones importantes con `memory-keeper`; después usar `/compact` en Claude Code o el mecanismo equivalente en otro harness. La memoria portable en `docs/memory/` debe ser la fuente estable que sobrevive al compact/reinicio.

**Why:** Estas decisiones evitan mezclar instrucciones para humanos no técnicos, depuración técnica y mantenimiento interno; también reducen el riesgo de que un instalador modifique el repo o de que una compactación pierda decisiones no persistidas.
**How to apply:** Al tocar documentación de usuario, mantener la separación por audiencia. Al tocar bootstrap/install, preservar la frontera bootstrap = máquina global, install = conexión/refresco, build_index = mantenimiento. Antes de sugerir compactación, comprobar que lo importante está guardado en memoria portable.
