# Depuración Del Bootstrap Para LLM

Esta guía está escrita para un LLM que ayuda a una persona a instalar
`biblio_skills`. Su objetivo es que el LLM entienda el contrato técnico del
bootstrap y pueda diagnosticar fallos sin inventar.

## Contrato Del Bootstrap

Secuencia esperada:

```text
Antigravity instalado
biblio_skills descargado o clonado
setup/bootstrap-machine.ps1 ejecutado desde la raíz del repo
toolchain global instalado/verificado
install.ps1 ejecutado
Antigravity reabierto
skills disponibles en el agente nativo
```

El bootstrap Windows vive en:

```text
setup/bootstrap-machine.ps1
```

Se ejecuta desde la raíz del repo:

```powershell
pwsh -File setup\bootstrap-machine.ps1
```

Modo de simulación:

```powershell
pwsh -File setup\bootstrap-machine.ps1 -DryRun
```

Instalación de workflows en un proyecto:

```powershell
pwsh -File setup\bootstrap-machine.ps1 -Project C:\ruta\a\repo
```

## Qué Debe Instalar O Verificar

Precondición:

- Antigravity ya está instalado.

Base del sistema:

- `git` vía `winget` (`Git.Git`).
- `gh` vía `winget` (`GitHub.cli`).
- `uv` vía `winget` (`astral-sh.uv`).
- Node.js/npm vía `winget` (`OpenJS.NodeJS.LTS`).

GitHub:

- `gh auth status` debe pasar.
- Si falla, la persona debe ejecutar `gh auth login`.

Python y CLIs de calidad:

- `uv python install 3.14`.
- `uv tool install --upgrade pre-commit`.
- `uv tool install --upgrade detect-secrets`.
- `uv tool install --upgrade ruff`.

Herramientas externas:

- Poppler vía `winget` (`oschwartz10612.Poppler`).
- Deben existir `pdfinfo`, `pdftotext`, `pdffonts`, `pdftoppm`.

CLIs LLM auxiliares:

- Claude Code: `winget install Anthropic.ClaudeCode`.
- Codex CLI: `npm install -g @openai/codex`.
- Gemini CLI: `npm install -g @google/gemini-cli`.

Conexión con Antigravity:

- El bootstrap llama a `install.ps1`.
- `install.ps1` enlaza skills y propaga rules.

## Qué No Debe Hacer

- No instala Antigravity.
- No crea proyectos nuevos.
- No instala dependencias de proyectos concretos.
- No edita `requirements.lock` de ningún repo.
- No debe borrar carpetas reales de skills si no son junctions/symlinks suyos.

## Rutas Importantes

Repo local:

```text
<carpeta>\biblio_skills
```

Skills globales de Antigravity:

```text
%USERPROFILE%\.gemini\antigravity\skills
```

Rules globales de Antigravity:

```text
%USERPROFILE%\.gemini\GEMINI.md
```

Workflows por proyecto:

```text
<repo>\.agents\workflows
```

Ficheros clave del repo:

```text
setup\bootstrap-machine.ps1
install.ps1
rules\
skills\
workflows\
docs\ANTIGRAVITY.md
```

## Qué Hace `install.ps1`

`install.ps1` es la conexión entre `biblio_skills` y Antigravity en Windows.

Hace tres cosas:

1. Crea junctions desde `skills/<nombre>` hacia:

   ```text
   %USERPROFILE%\.gemini\antigravity\skills\<nombre>
   ```

2. Escribe un bloque gestionado de rules en:

   ```text
   %USERPROFILE%\.gemini\GEMINI.md
   ```

3. Si recibe `-Project <ruta>`, instala workflows en:

   ```text
   <repo>\.agents\workflows
   ```

`install.ps1 -DryRun` debe mostrar qué haría sin tocar nada.

## Diagnóstico Rápido

Pide a la persona ejecutar estos comandos desde PowerShell:

```powershell
$PSVersionTable.PSVersion
Get-Command pwsh,winget,git,gh,uv,node,npm,python,pre-commit,detect-secrets,ruff,codex,claude,gemini,pdfinfo,pdftotext,pdffonts,pdftoppm,antigravity -ErrorAction SilentlyContinue | Select-Object Name,Source
gh auth status
pwsh -File setup\bootstrap-machine.ps1 -DryRun
```

Si `pwsh` no existe, instalar PowerShell 7 o ejecutar desde el PowerShell que
Antigravity/Windows haya instalado, pero el camino documentado es `pwsh`.

Si `winget` no existe, falta App Installer o está roto el entorno base de
Windows. El bootstrap necesita `winget` para instalar paquetes de sistema.

Si `gh auth status` falla, ejecutar:

```powershell
gh auth login
```

Si una herramienta se instala pero sigue sin aparecer, sospecha de PATH. Cerrar
PowerShell, abrir una ventana nueva y reejecutar el bootstrap suele resolverlo.

## Fallos Frecuentes

### La Persona No Está En La Carpeta Correcta

Síntoma:

```text
The argument 'setup\bootstrap-machine.ps1' is not recognized
Cannot find path setup\bootstrap-machine.ps1
```

Causa probable:

PowerShell no está abierto en la raíz de `biblio_skills`.

Comprobación:

```powershell
dir
```

Debe mostrar:

```text
README.md
AGENTS.md
install.ps1
setup
skills
rules
```

### GitHub CLI No Está Autenticado

Síntoma:

```text
GitHub CLI no esta autenticado
```

Solución:

```powershell
gh auth login
pwsh -File setup\bootstrap-machine.ps1
```

### Winget Instaló Algo Pero No Aparece En PATH

Síntoma:

```text
se instalo o intento instalarse, pero '<comando>' no aparece en PATH
```

Solución:

1. Cerrar PowerShell.
2. Abrir PowerShell de nuevo en la carpeta `biblio_skills`.
3. Reejecutar:

   ```powershell
   pwsh -File setup\bootstrap-machine.ps1
   ```

### Antigravity No Ve Las Skills

Comprobaciones:

1. Cerrar y reabrir Antigravity.
2. Usar el agente nativo de Antigravity, no el panel Claude Code.
3. Verificar que existen junctions en:

   ```powershell
   dir $HOME\.gemini\antigravity\skills
   ```

4. Ejecutar:

   ```powershell
   pwsh -File install.ps1 -DryRun
   pwsh -File install.ps1
   ```

### `/cierre` No Aparece

Esto no es necesariamente un fallo. Los workflows no son globales en
Antigravity. Se instalan por proyecto.

Ejecutar desde `biblio_skills`:

```powershell
pwsh -File install.ps1 -Project C:\ruta\a\repo
```

Luego reabrir ese repo en Antigravity y escribir `/` en el agente nativo.

## Criterio De Éxito

El bootstrap está bien si:

- `pwsh -File setup\bootstrap-machine.ps1 -DryRun` no muestra errores.
- `gh auth status` pasa.
- `Get-Command codex,claude,gemini` devuelve rutas.
- `Get-Command pdfinfo,pdftotext,pdffonts,pdftoppm` devuelve rutas.
- `dir $HOME\.gemini\antigravity\skills` muestra skills de `biblio_skills`.
- Antigravity reabierto puede responder qué skills tiene disponibles.

## Regla De Oro Para El LLM

No parches al azar. Primero identifica en qué fase falló:

```text
carpeta incorrecta
PowerShell/pwsh
winget
GitHub auth
uv/Python
npm/CLIs LLM
Poppler
install.ps1
Antigravity no recargado
panel equivocado
workflow no instalado por proyecto
```

Después corrige esa fase y reejecuta el bootstrap. El script está diseñado para
ser idempotente.
