<#
install.ps1 — Instalador de biblio_skills para Windows + Antigravity.

Crea junctions (no symlinks: no requieren admin y Antigravity las ve como carpetas
normales) desde biblio_skills/skills/* hacia la carpeta de skills globales que
Antigravity escanea, escribe un bloque de reglas gestionado en el GEMINI.md global,
y embebe las reglas en el AGENTS.md del repo (para Codex y modelos que no resuelven @import).

biblio_skills/skills|rules son la ÚNICA fuente de verdad; esto solo enlaza/propaga.

Uso:
  pwsh -File install.ps1            # instala
  pwsh -File install.ps1 -DryRun    # muestra qué haría, sin tocar nada
#>
param([switch]$DryRun, [string]$Project)

$ErrorActionPreference = "Stop"

# Raíz del repo = carpeta de este script
$Repo        = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsSrc   = Join-Path $Repo "skills"
$RulesSrc    = Join-Path $Repo "rules"
$SkillsDst   = Join-Path $HOME ".gemini\antigravity\skills"     # confirmado por ping-test
$GeminiMd    = Join-Path $HOME ".gemini\GEMINI.md"
$AgentsMd    = Join-Path $Repo "AGENTS.md"
$CommandsSrc = Join-Path $Repo "workflows\commands"
$CommandsDst = Join-Path $HOME ".claude\commands"

# Bloque GEMINI.md: 1 = referencias @ruta (Antigravity las resuelve); 0 = contenido embebido
$Reference   = 1
$Begin       = "# >>> biblio_skills:rules (gestionado por install.ps1) >>>"
$End         = "# <<< biblio_skills:rules <<<"
# Bloque AGENTS.md: siempre contenido embebido (Codex no resuelve @import ni rutas Windows)
$AgentsBegin = "<!-- BEGIN biblio_skills:rules (autogenerado por install.ps1 - no editar a mano) -->"
$AgentsEnd   = "<!-- END biblio_skills:rules -->"

function Act([string]$msg, [scriptblock]$do) {
  if ($DryRun) { Write-Host "  [dry-run] $msg" }
  else         { & $do; Write-Host "  OK $msg" }
}

# Genera el texto del bloque gestionado de reglas.
# Mode: 1 = referencias @ruta, 0 = contenido embebido. Eol: separador de línea.
function New-RulesBlock([string]$BeginMarker, [string]$EndMarker, $Files, [int]$Mode, [string]$Eol) {
    $lines = @($BeginMarker)
    foreach ($f in $Files) {
        if ($Mode -eq 1) { $lines += "@$($f.FullName)" }
        else             { $lines += ""; $lines += ([System.IO.File]::ReadAllText($f.FullName, [System.Text.UTF8Encoding]::new($false))).TrimEnd() }
    }
    $lines += $EndMarker
    return $lines -join $Eol
}

# Reemplaza idempotentemente un bloque gestionado al final del fichero destino.
# NoBom=$true → UTF-8 sin BOM (obligatorio para ficheros rastreados por git).
function Set-ManagedBlock([string]$Path, [string]$BlockText, [string]$BeginMarker, [string]$EndMarker, [bool]$NoBom) {
    New-Item -ItemType Directory -Force -Path (Split-Path $Path) | Out-Null
    if (-not (Test-Path $Path)) { New-Item -ItemType File -Path $Path | Out-Null }
    if (Test-Path $Path) { $current = [System.IO.File]::ReadAllText($Path, [System.Text.UTF8Encoding]::new($false)) } else { $current = "" }
    $pat = [regex]::Escape($BeginMarker) + "[\s\S]*?" + [regex]::Escape($EndMarker)
    $cleaned = [regex]::Replace($current, $pat, "").TrimEnd()
    $eol = if ($NoBom) { "`n" } else { "`r`n" }
    $new = if ($cleaned) { "$cleaned$eol$eol$BlockText$eol" } else { "$BlockText$eol" }
    if ($NoBom) {
        [System.IO.File]::WriteAllText($Path, $new, (New-Object System.Text.UTF8Encoding($false)))
    } else {
        Set-Content -Path $Path -Value $new -Encoding utf8
    }
}

Write-Host "biblio_skills install (repo: $Repo)"
if ($DryRun) { Write-Host "MODO DRY-RUN: no se toca nada." }

# 1) Skills -> junctions en la carpeta global de Antigravity
Write-Host "`n1) Skills -> $SkillsDst"
Act "mkdir $SkillsDst" { New-Item -ItemType Directory -Force -Path $SkillsDst | Out-Null }
Get-ChildItem -Directory $SkillsSrc | ForEach-Object {
  $name = $_.Name
  $dst  = Join-Path $SkillsDst $name
  $src  = $_.FullName
  if (Test-Path $dst) {
    $item = Get-Item $dst -Force
    $isReparse = $item.Attributes -band [IO.FileAttributes]::ReparsePoint
    if ($isReparse) {
      Act "elimina junction previa $name" {
        # es un reparse point (junction): borrar el enlace no toca el contenido origen
        $item.Delete()
      }
    } else {
      Write-Host "  X ABORTA: '$dst' existe y NO es una junction (carpeta/archivo real) -- no lo toco. Resuelvelo a mano." -ForegroundColor Red
      return
    }
  }
  Act "junction $name -> $src" {
    New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
  }
}

# 2) Reglas -> GEMINI.md (Antigravity) y AGENTS.md (Codex / modelos sin resolución de @import)
Write-Host "`n2) Reglas -> $GeminiMd y $AgentsMd"
$ruleFiles = Get-ChildItem -File (Join-Path $RulesSrc "*.md") |
             Where-Object { $_.Name -ne "00-index.md" }

# 2a) GEMINI.md — referencias @ruta, CRLF; fuera de git, puede tener BOM
$geminiBlock = New-RulesBlock $Begin $End $ruleFiles $Reference "`r`n"
if ($DryRun) {
    Write-Host "  [dry-run] actualizaria el bloque en $GeminiMd :"
    $geminiBlock -split "`r`n" | ForEach-Object { Write-Host "      $_" }
} else {
    Set-ManagedBlock $GeminiMd $geminiBlock $Begin $End $false
    Write-Host "  OK bloque biblio_skills:rules actualizado en $GeminiMd"
}

# 2b) AGENTS.md — contenido embebido, LF, sin BOM (fichero rastreado por git)
$agentsBlock = New-RulesBlock $AgentsBegin $AgentsEnd $ruleFiles 0 "`n"
if ($DryRun) {
    Write-Host "  [dry-run] actualizaria el bloque en $AgentsMd :"
    $agentsBlock -split "`n" | ForEach-Object { Write-Host "      $_" }
    if ($agentsBlock -match [regex]::Escape($Repo)) {
        Write-Host "  [AVISO] el bloque contiene rutas absolutas de Windows" -ForegroundColor Yellow
    } else {
        Write-Host "  [OK] el bloque no contiene rutas absolutas de Windows" -ForegroundColor Green
    }
} else {
    Set-ManagedBlock $AgentsMd $agentsBlock $AgentsBegin $AgentsEnd $true
    Write-Host "  OK bloque biblio_skills:rules actualizado en $AgentsMd"
}

Write-Host "`nHecho."
Write-Host "Verifica en Antigravity (cierra y reabre): /skills debe listar las de biblio_skills,"

# 4) Workflows invocables -> ~/.claude/commands/ (slash commands globales de Claude Code)
Write-Host "`n4) Workflows invocables -> $CommandsDst"
Act "mkdir $CommandsDst" { New-Item -ItemType Directory -Force -Path $CommandsDst | Out-Null }
if (Test-Path $CommandsSrc) {
    Get-ChildItem -File (Join-Path $CommandsSrc "*.md") | ForEach-Object {
        $dst = Join-Path $CommandsDst $_.Name
        if (Test-Path $dst) { Act "elimina $($_.Name) previo" { Remove-Item -Force $dst } }
        Act "hardlink command $($_.Name)" {
            try   { New-Item -ItemType HardLink -Path $dst -Target $_.FullName | Out-Null }
            catch { Copy-Item -Path $_.FullName -Destination $dst -Force }
        }
    }
} else {
    Write-Host "  (workflows\commands\ no existe en el repo - omitido)"
}

# 5) Workflows -> SOLO por proyecto (no hay global). Requiere -Project <ruta_repo>.
if ($Project) {
  $wfSrc = Join-Path $Repo "workflows"
  $wfDst = Join-Path $Project ".agents\workflows"
  Write-Host "`n3) Workflows -> $wfDst (workspace; no hay ruta global)"
  Act "mkdir $wfDst" { New-Item -ItemType Directory -Force -Path $wfDst | Out-Null }
  Get-ChildItem -File (Join-Path $wfSrc "*.md") | ForEach-Object {
    $dst = Join-Path $wfDst $_.Name
    if (Test-Path $dst) { Act "elimina $($_.Name) previo" { Remove-Item -Force $dst } }
    # Hard link (ficheros, mismo volumen, sin admin). Si fallara (otro volumen), copia.
    Act "hardlink workflow $($_.Name)" {
      try   { New-Item -ItemType HardLink -Path $dst -Target $_.FullName | Out-Null }
      catch { Copy-Item -Path $_.FullName -Destination $dst -Force }
    }
  }
} else {
  Write-Host "`n5) Workflows: omitidos (pasa -Project <ruta_repo> para instalar /cierre en .agents\workflows de ese repo)."
}

Write-Host "y una regla del bloque debe respetarse. Edita en biblio_skills y reejecuta para propagar."
Write-Host "Skills de proyecto: van en <repo>\.agents\skills\ (ganan prioridad sobre la global)."
