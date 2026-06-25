---
name: audit-board
maturity: validated
description: "Adversarial multi-role audit of any production or research system. Dispatches N parallel agents (each covering a role cluster) then a synthesis agent. Use when a project has real risk (production code, capital, users, data integrity) and needs rigorous external-style review. Trigger: /audit-board"
trigger: /audit-board
---

# /audit-board

Orchestrate an adversarial institutional audit across parallel agents. Domain-agnostic: the framework is fixed, the expert roles are project-specific (defined in the project's `audit_board_profile.md`).

## Usage

```
/audit-board                        # run Full audit using profile in research/audit_board_profile.md
/audit-board <profile_path>         # run Full audit with explicit profile path
/audit-board --tier quick           # Quick audit (30-40% of roles, fastest)
/audit-board --tier standard        # Standard audit (50-60% of roles)
/audit-board --tier full            # Full audit — all roles (default)
/audit-board --init                 # Create a new audit_board_profile.md for this project
```

## When to use

- Before activating a production system with real capital, users, or data
- Periodically while a production system is active (quarterly or after significant changes)
- When inheriting unknown code that is already in production
- Before a major architectural decision or phase transition
- After accumulating significant changes (e.g. ≥8 commits to core logic)

Do NOT use for hobby projects with no production risk — the overhead is not justified.

## What it produces

- **Fase 1 outputs**: one file per cluster (`research/results/audit_YYYY_MM_DD_part_CLUSTER.md`)
- **Fase 2 output**: consolidated synthesis (`research/results/audit_board_vX_YYYY_MM_DD.md`)

---

## How to run an audit

### Step 1 — Read the profile
Read `research/audit_board_profile.md` (or the path provided). It defines:
- The role clusters and their assignments
- The context bundle for each cluster
- The specific debates for Fase 2
- Any project-specific rules additions

### Step 2 — Read FRAMEWORK.md
Read `FRAMEWORK.md` (en este mismo directorio de skill) for the generic pipeline, prompt templates, scoring rubric, and output format.

### Step 3 — Dispatch Fase 1 agents in parallel
Launch ALL cluster agents in a single message (one Agent tool call per cluster).
Use the prompt template from FRAMEWORK.md, substituting values from the profile.
Each agent writes its output file before returning.

### Step 4 — Wait for all Fase 1 agents, then dispatch Fase 2
When all cluster outputs exist on disk, launch the single synthesis agent.
It executes: Devil's Advocate role, System Decomposition role, Attribution role, debates, and meta-review.

### Step 5 — Report to user
Summarize top findings. Point to the consolidated output file.

---

## /audit-board --init (creating a profile for a new project)

When invoked with `--init`, guide the user through defining their project's profile.

Ask these questions in order:

1. **Domain**: What does this system do? (e.g. crypto arbitrage, web platform, data pipeline)
2. **Risk profile**: Is it in production? Does it handle real capital, user data, or critical infrastructure?
3. **Scale**: How many roles make sense? (Quick: 5-7, Standard: 10-12, Full: 15-20)
4. **Biggest risk**: What is the single most dangerous failure mode of this system?
5. **Context bundle**: What files give an auditor enough context? (main logic, config, architecture doc, data model)

Based on answers, generate role suggestions covering:
- Data/input quality (always relevant)
- Core domain logic correctness (domain-specific)
- Operational reliability / SRE
- Security (scale to system's risk surface)
- Architecture / systems design
- Governance / compliance (if applicable)
- External benchmark (compare against professional standard)
- Devil's Advocate (always in Fase 2)

Then help the user write each role following the ROLE_SCHEMA in FRAMEWORK.md.

Output: a complete `audit_board_profile.md` in the project's `research/` directory (or root if no `research/` exists).

---

## Notes

- The framework (this file + FRAMEWORK.md) never changes per project. Only the profile changes.
- Roles must be adversarial — see REGLAS ABSOLUTAS in FRAMEWORK.md.
- The synthesis agent (Fase 2) must always include a Devil's Advocate role that explicitly attacks the findings of Fase 1.
- A Quick audit with 5 well-designed roles beats a Full audit with 20 generic roles.

---

## Nota de plataforma (Antigravity)

- En Antigravity los agentes paralelos de Fase 1 se despachan como **subagentes**
  (Manager view / subagentes asíncronos), no con el "Agent tool" de Claude Code.
  El patrón es el mismo: un subagente por cluster, cada uno escribe su fichero antes
  de volver; luego un subagente de síntesis.
- Asigna a la síntesis y al Devil's Advocate un **modelo de familia distinta** al que
  generó el trabajo auditado, para independencia fuerte (ver `multi-agent-collaboration`).
- Relación con otros activos: `audit-board` es una auditoría **pesada, multi-rol, puntual**
  (subagentes internos). `/auditoria-externa` es una **segunda opinión única** de un modelo
  externo. `multi-agent-collaboration` es el **protocolo continuo** del día a día.
