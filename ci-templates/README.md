# ci-templates — barreras duras por proyecto

Estas plantillas enforcan lo **determinista** (lo que una máquina puede comprobar) y
**no** se instalan globalmente: se copian a cada proyecto. La razón es que dependen del
gestor de paquetes, los paths y la suite de cada repo.

Reparto con las `rules/`: la regla define el *estándar y el criterio* (juicio); estas
plantillas son el *gate que bloquea* (determinista). No mandes a un LLM a hacer el
trabajo de un linter.

## Qué hay aquí

| Fichero                     | Enforca                                                  |
| --------------------------- | -------------------------------------------------------- |
| `pre-commit-config.yaml`    | secretos comiteados, encoding UTF-8, higiene básica      |
| `github-actions-ci.yml`     | suite de tests verde como gate del PR                    |
| `check_encoding.py`         | secuencias de mojibake (ej. `Ã±`) en ficheros de texto   |

## Instalación en un proyecto

```bash
# desde la raíz del proyecto destino
cp <biblio_skills>/ci-templates/pre-commit-config.yaml .pre-commit-config.yaml
mkdir -p .github/workflows scripts
cp <biblio_skills>/ci-templates/github-actions-ci.yml .github/workflows/ci.yml
cp <biblio_skills>/ci-templates/check_encoding.py scripts/check_encoding.py

pip install pre-commit detect-secrets
pre-commit install                      # activa el hook local
detect-secrets scan > .secrets.baseline # baseline inicial de secretos
```

Ajusta el comando de tests en `github-actions-ci.yml` al de tu proyecto.
