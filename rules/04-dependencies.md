# Dependencias

Convención canónica del proyecto (por repo): **`requirements.in` + `requirements.lock`**, no
un `requirements.txt` mantenido a mano.

- *`requirements.in`* — dependencias **directas**, con el rango/versión mínima que necesites y
  un comentario de propósito. Si una dep es de infra/desarrollo (no de negocio), va en sección
  separada.
- *`requirements.lock`* — árbol completo clavado: `uv pip compile requirements.in -o requirements.lock`.
  Es lo reproducible y **va en git**. Se restaura con `uv pip sync requirements.lock`.
- No inventes dependencias: antes de un `import`, verifica que la librería existe y está
  declarada en `requirements.in`. Nunca asumas que está disponible sin comprobarlo.
- Objetivo: que `uv pip sync requirements.lock` reconstruya el entorno exacto, sin dependencias
  fantasma ni drift de versiones.

**Toolchain global (por máquina, NO por proyecto):** versión de Python, CLIs de calidad
(pre-commit, ruff, detect-secrets) y herramientas de sistema (poppler). Se instala una vez con
`setup/bootstrap-machine.sh`. Un `requirements.lock` global es un anti-patrón: rompe el
aislamiento y provoca conflictos de versión entre proyectos. Los instalables no-pip se declaran
en la sección "Comandos" del `AGENTS.md` del repo.

[CI] La coherencia "lo importado está declarado / lo declarado está instalado" es
comprobable y se enforca en pre-commit (ver `ci-templates/`).
