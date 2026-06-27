<#
bootstrap-machine.ps1 - prepara una maquina Windows para vivir en Antigravity con biblio_skills.

Secuencia esperada:
  1. Instalar Antigravity.
  2. Clonar biblio_skills.
  3. Ejecutar este script desde la raiz del repo:
       pwsh -File setup\bootstrap-machine.ps1

El script configura el toolchain global de la maquina y despues conecta
biblio_skills con Antigravity mediante install.ps1. No instala dependencias de
proyecto: cada repo mantiene su propio requirements.in + requirements.lock.
#>
param(
  [switch]$DryRun,
  [string]$Project,
  [switch]$SkipInstall
)

$ErrorActionPreference = "Stop"

$PythonVersion = "3.14"
$GlobalUvTools = @("pre-commit", "detect-secrets", "ruff")
$GlobalNpmTools = @(
  @{ Command = "codex"; Package = "@openai/codex"; Name = "Codex CLI" },
  @{ Command = "gemini"; Package = "@google/gemini-cli"; Name = "Gemini CLI" }
)
$Repo = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$InstallScript = Join-Path $Repo "install.ps1"

function Has-Command([string]$Name) {
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Step([string]$Message, [scriptblock]$Action) {
  if ($DryRun) {
    Write-Host "  [dry-run] $Message"
  } else {
    & $Action
    Write-Host "  OK $Message"
  }
}

function Require-Command([string]$Name, [string]$Help) {
  if (-not (Has-Command $Name)) {
    throw "Falta '$Name'. $Help"
  }
}

function Install-WingetPackage([string]$Id, [string]$Name) {
  Require-Command "winget" "Instala App Installer/winget o instala $Name manualmente."
  Step "winget install $Name ($Id)" {
    winget install --id $Id --exact --accept-package-agreements --accept-source-agreements
  }
}

function Ensure-WingetPackage([string]$Command, [string]$Id, [string]$Name) {
  if (Has-Command $Command) {
    Write-Host "  OK ${Name}: $((Get-Command $Command).Source)"
  } else {
    Install-WingetPackage $Id $Name
    if ($DryRun) { return }
    if (-not (Has-Command $Command)) {
      throw "$Name se instalo o intento instalarse, pero '$Command' no aparece en PATH. Abre una terminal nueva y reejecuta."
    }
  }
}

function Ensure-UvTool([string]$Tool) {
  Step "uv tool install --upgrade $Tool" {
    uv tool install --upgrade $Tool
  }
}

function Ensure-NpmTool([string]$Command, [string]$Package, [string]$Name) {
  if (Has-Command $Command) {
    Write-Host "  OK ${Name}: $((Get-Command $Command).Source)"
  } else {
    Require-Command "npm" "Instala Node.js/npm o deja que el bootstrap instale Node.js LTS antes de instalar $Name."
    Step "npm install -g $Package" {
      npm install -g $Package
    }
    if ($DryRun) { return }
    if (-not (Has-Command $Command)) {
      throw "$Name se instalo o intento instalarse, pero '$Command' no aparece en PATH. Abre una terminal nueva y reejecuta."
    }
  }
}

function Test-AntigravityInstalled {
  if (Has-Command "antigravity") { return $true }
  $candidates = @(
    (Join-Path $env:LOCALAPPDATA "Programs\Antigravity\bin\antigravity.cmd"),
    (Join-Path $env:LOCALAPPDATA "Programs\Antigravity\Antigravity.exe"),
    (Join-Path $env:ProgramFiles "Antigravity\Antigravity.exe")
  )
  foreach ($path in $candidates) {
    if (Test-Path $path) { return $true }
  }
  return $false
}

Write-Host "== biblio_skills :: bootstrap de maquina Windows =="
Write-Host "repo: $Repo"
if ($DryRun) { Write-Host "MODO DRY-RUN: no se toca nada." }

Write-Host "`n1) Precondicion: Antigravity"
if (Test-AntigravityInstalled) {
  Write-Host "  OK Antigravity instalado"
} else {
  throw "No encuentro Antigravity. Instala Antigravity primero, abre una terminal nueva y reejecuta este script."
}

Write-Host "`n2) Base del sistema"
Ensure-WingetPackage "git" "Git.Git" "Git"
Ensure-WingetPackage "gh" "GitHub.cli" "GitHub CLI"
Ensure-WingetPackage "uv" "astral-sh.uv" "uv"
Ensure-WingetPackage "node" "OpenJS.NodeJS.LTS" "Node.js LTS"

Write-Host "`n3) GitHub"
if ($DryRun) {
  Write-Host "  [dry-run] gh auth status"
} else {
  gh auth status
  if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI no esta autenticado. Ejecuta 'gh auth login' y reejecuta bootstrap-machine."
  }
}

Write-Host "`n4) Python gestionado por uv"
Step "uv python install $PythonVersion" {
  uv python install $PythonVersion
}

Write-Host "`n5) CLIs globales aisladas"
foreach ($tool in $GlobalUvTools) {
  Ensure-UvTool $tool
}

Write-Host "`n6) Herramientas externas"
Ensure-WingetPackage "pdfinfo" "oschwartz10612.Poppler" "Poppler"
$popplerTools = @("pdfinfo", "pdftotext", "pdffonts", "pdftoppm")
foreach ($tool in $popplerTools) {
  Require-Command $tool "Poppler debe exponer $tool en PATH. Abre una terminal nueva y reejecuta."
}
Write-Host "  OK Poppler: $($popplerTools -join ', ')"

Write-Host "`n7) CLIs LLM"
Ensure-WingetPackage "claude" "Anthropic.ClaudeCode" "Claude Code"
foreach ($tool in $GlobalNpmTools) {
  Ensure-NpmTool $tool.Command $tool.Package $tool.Name
}
if ($DryRun) {
  Write-Host "  [dry-run] CLIs LLM verificadas o planificadas: codex, claude, gemini"
} else {
  Write-Host "  OK CLIs LLM: codex, claude, gemini"
}
Write-Host "  Nota: biblio_skills se instala para el agente nativo de Antigravity; estos CLIs son auxiliares."

Write-Host "`n8) Conectar biblio_skills con Antigravity"
if ($SkipInstall) {
  Write-Host "  OMITIDO por -SkipInstall"
} else {
  if (-not (Test-Path $InstallScript)) {
    throw "No encuentro install.ps1 en $InstallScript"
  }
  $installArgs = @()
  if ($DryRun) { $installArgs += "-DryRun" }
  if ($Project) { $installArgs += @("-Project", $Project) }
  Step "pwsh -File install.ps1 $($installArgs -join ' ')" {
    & pwsh -File $InstallScript @installArgs
  }
}

Write-Host "`n== Bootstrap completado =="
Write-Host "Reabre Antigravity. En el agente nativo, pide: 'que skills tienes disponibles?'"
Write-Host "Para un proyecto nuevo, pide en chat: 'Voy a empezar un proyecto nuevo. Usa project-bootstrap.'"
