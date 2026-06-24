<#
install.ps1 — Instalador de biblio_skills para Windows + Antigravity.

Crea junctions (no symlinks: no requieren admin y Antigravity las ve como carpetas
normales) desde biblio_skills/skills/* hacia la carpeta de skills globales que
Antigravity escanea, y escribe un bloque de reglas gestionado en el GEMINI.md global.

biblio_skills/skills|rules son la ÚNICA fuente de verdad; esto solo enlaza/propaga.

Uso:
  pwsh -File install.ps1            # instala
  pwsh -File install.ps1 -DryRun    # muestra qué haría, sin tocar nada
#>
param([switch]$DryRun)

$ErrorActionPreference = "Stop"

# Raíz del repo = carpeta de este script
$Repo        = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsSrc   = Join-Path $Repo "skills"
$RulesSrc    = Join-Path $Repo "rules"
$SkillsDst   = Join-Path $HOME ".gemini\antigravity\skills"     # confirmado por ping-test
$GeminiMd    = Join-Path $HOME ".gemini\GEMINI.md"

# Bloque de reglas: 1 = referenciar con @ruta (recomendado); 0 = concatenar contenido
$Reference   = 1
$Begin       = "# >>> biblio_skills:rules (gestionado por install.ps1) >>>"
$End         = "# <<< biblio_skills:rules <<<"

function Act([string]$msg, [scriptblock]$do) {
  if ($DryRun) { Write-Host "  [dry-run] $msg" }
  else         { & $do; Write-Host "  OK $msg" }
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
    Act "elimina junction/carpeta previa $name" {
      # Remove-Item sobre una junction borra el enlace, no el contenido origen
      (Get-Item $dst).Delete()
    }
  }
  Act "junction $name -> $src" {
    New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
  }
}

# 2) Reglas -> bloque gestionado en GEMINI.md global
Write-Host "`n2) Reglas -> $GeminiMd"
$ruleFiles = Get-ChildItem -File (Join-Path $RulesSrc "*.md") |
             Where-Object { $_.Name -ne "00-index.md" }

$block = @($Begin)
foreach ($f in $ruleFiles) {
  if ($Reference -eq 1) { $block += "@$($f.FullName)" }
  else                  { $block += ""; $block += (Get-Content -Raw $f.FullName) }
}
$block += $End
$blockText = $block -join "`r`n"

if ($DryRun) {
  Write-Host "  [dry-run] actualizaria el bloque en $GeminiMd :"
  $blockText -split "`r`n" | ForEach-Object { Write-Host "      $_" }
} else {
  New-Item -ItemType Directory -Force -Path (Split-Path $GeminiMd) | Out-Null
  if (-not (Test-Path $GeminiMd)) { New-Item -ItemType File -Path $GeminiMd | Out-Null }
  $content = Get-Content -Raw $GeminiMd -ErrorAction SilentlyContinue
  if ($null -eq $content) { $content = "" }
  # elimina un bloque previo gestionado (idempotente)
  $pattern = [regex]::Escape($Begin) + "[\s\S]*?" + [regex]::Escape($End)
  $content = [regex]::Replace($content, $pattern, "").TrimEnd()
  $new = if ($content) { "$content`r`n`r`n$blockText`r`n" } else { "$blockText`r`n" }
  Set-Content -Path $GeminiMd -Value $new -Encoding utf8
  Write-Host "  OK bloque biblio_skills:rules actualizado en $GeminiMd"
}

Write-Host "`nHecho."
Write-Host "Verifica en Antigravity (cierra y reabre): /skills debe listar las de biblio_skills,"
Write-Host "y una regla del bloque debe respetarse. Edita en biblio_skills y reejecuta para propagar."
Write-Host "Skills de proyecto: van en <repo>\.agents\skills\ (ganan prioridad sobre la global)."
