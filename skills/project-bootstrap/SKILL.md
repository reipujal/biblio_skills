---
name: project-bootstrap
description: Arranca un proyecto nuevo asistido por IA con la estructura, gobierno y barreras correctas desde el primer commit. Úsala SIEMPRE que el usuario empiece un proyecto desde cero, cree un repositorio nuevo, diga "nuevo proyecto", "arrancar", "scaffolding", "montar el repo", o pida estructura inicial / AGENTS.md / .gitignore / setup de tests o CI. Incluso si solo menciona "voy a empezar algo nuevo", ofrécela.
---

# Project Bootstrap

Arranca un proyecto serio (Python por defecto) con gobierno, reproducibilidad,
seguridad y testing listos desde el inicio. No produce prototipos: produce un repo
auditable desde la primera línea.

Las prácticas de calidad NO se repiten aquí: esta skill **referencia** las `rules/`
universales (secretos, tests, dependencias, git). Esta skill añade solo lo específico
del arranque.

## Procedimiento

1. **Estructura mínima** (crecer solo si hace falta):

   ```
   <proyecto>/
   ├── AGENTS.md            # gobierno del proyecto (Antigravity lo lee nativo)
   ├── README.md
   ├── .gitignore
   ├── .env.example         # plantilla sin valores reales
   ├── requirements.txt     # versiones fijadas
   ├── requirements.lock    # reproducibilidad estricta (opcional pero recomendado)
   ├── src/  (o main.py)
   └── tests/
   ```

2. **Gobierno del proyecto** → copia `templates/AGENTS.project.md` y rellénalo. NO es
   un `CLAUDE.md`: en Antigravity el fichero nativo es `AGENTS.md`. Debe declarar qué
   `rules/` globales aplican y la convención de ese proyecto concreto.

3. **Barreras duras** → instala las `ci-templates/` del repo (pre-commit + GitHub
   Actions). Ver `ci-templates/README.md`. Esto enforca lo determinista: tests verdes,
   secretos, encoding.

4. **Reproducibilidad** → `requirements.txt` con versiones fijadas (regla `04`); genera
   `requirements.lock` para clavar el árbol completo.

5. **Seguridad de arranque** → `.gitignore` excluye `.env`, outputs, logs, caches
   (`templates/gitignore.txt`). `.env.example` con las variables sin valores.

6. **Git + remote** → `git init`, primer commit, crea el remote en GitHub y `git push`.
   Sin remote no hay backup (regla `05`). El remote público además habilita auditoría
   externa por Gemini/GPT.

7. **Verificación de arranque** → la suite (aunque sea un test trivial) pasa en verde y
   el pre-commit se ejecuta limpio antes de cerrar.

## Recursos

- `templates/AGENTS.project.md` — gobierno de proyecto a rellenar.
- `templates/gitignore.txt` — `.gitignore` base.
- `templates/env.example.txt` — `.env.example` base.
- `ci-templates/` (raíz del repo) — barreras duras por proyecto.
