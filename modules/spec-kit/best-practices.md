# Best Practices for GitHub Spec-Kit (Spec-Driven Development)

**Document version:** May 2026  
**Sources:** Official GitHub Spec-Kit documentation, quickstart guide, CLI reference, community discussions, and real-world usage examples (github/spec-kit repo, GitHub Discussions, blog posts, YouTube guides).

## 1. Core Philosophy of Spec-Kit

Spec-Kit enforces **Spec-Driven Development (SDD)**:  
- Start with **what** and **why** (user-focused, tech-agnostic).  
- Only then move to **how** (technical plan).  
- Generate executable artifacts (`spec.md`, `plan.md`, tasks) that the AI agent follows strictly.  
- Heavy emphasis on iteration, validation, and guardrails (constitution).

**Key rule:** Never “vibe code”. Every feature follows the gated workflow: Constitution → Specify → (Clarify) → Plan → Tasks → (Analyze) → Implement.

## 2. Command-by-Command Best Practices for Free-Form Text Input

All commands accept **natural language** after the slash command. The text becomes the user prompt for that step.

### `/speckit.constitution` (one-time per project)
- **Purpose:** Define immutable project rules.
- **Best prompt style:** Authoritative, list-based principles.  
  **Good example:**  
  `This project follows a "Library-First" approach. All features must be implemented as standalone libraries first. We use strict TDD. We prefer immutable data structures, pure total functions, no implicit state, and make invalid states irrepresentable.`
- **Tip:** Keep it concise but comprehensive. This file is read on every subsequent command.

### `/speckit.specify` (core – raw idea → spec.md)
- **Purpose:** Create or update the functional specification (WHAT + WHY).
- **Best prompt style:** Detailed natural language. Focus exclusively on user needs, stories, edge cases, success metrics, constraints. **Never mention tech stack**.
- **Good examples:**
  - `Build an application that helps me organize my photos in separate albums. Albums are grouped by date and can be re-organized by dragging and dropping. Albums are never nested. Within each album photos are previewed in a tile-like interface.`
  - `Develop a team productivity platform called Taskify. Users create projects, add team members, assign tasks, comment, and move tasks in Kanban style. Include five predefined users (one PM, four engineers) and three sample projects.`
- **Tips:** Be verbose on first run. Include personas, flows, acceptance criteria, non-functional requirements (performance, privacy, offline). The more detail, the better the spec.

### `/speckit.clarify` (optional but highly recommended before planning)
- **Purpose:** Resolve ambiguities, edge cases, missing details.
- **Best prompt style:** Specific focus areas or additional requirements.
- **Good examples:**
  - `Focus on security, performance, and offline capabilities.`
  - `Clarify task card details: users should be able to change status by drag-and-drop, add unlimited comments, assign users, and edit/delete only their own comments.`
- **Tip:** Run this multiple times if needed. It enriches `spec.md` without overwriting structure.

### `/speckit.plan` (core – spec → technical plan.md)
- **Purpose:** Define HOW (tech stack, architecture, libraries).
- **Best prompt style:** Explicit and precise about technology choices.
- **Good examples:**
  - `Use Vite with minimal libraries. Prefer vanilla HTML, CSS, JavaScript. Store metadata in local SQLite.`
  - `Use .NET Aspire with Postgres. Frontend in Blazor Server with drag-and-drop. Include REST APIs for projects, tasks, and notifications.`
- **Tip:** Reference any project-specific constraints from constitution.

### `/speckit.tasks` (core)
- **Purpose:** Break plan into actionable tasks/phases.
- **Input:** Usually none (or very light clarification).  
  **Example (if needed):** `Focus on foundational tasks first and group related UI changes together.`

### `/speckit.taskstoissues` (optional)
- **Purpose:** Turn tasks into GitHub issues.
- **Input:** Usually none.

### `/speckit.analyze` (optional, recommended before implement)
- **Purpose:** Cross-check consistency between constitution, spec, plan, and tasks.
- **Input:** Usually none.  
  **Tip:** Run it multiple times. If it suggests changes, refine via `/clarify` or `/plan` instead of manual edits.

### `/speckit.checklist` (optional, flexible)
- **Purpose:** Generate quality/validation checklist.
- **Input:** Usually none (or specific focus: `Focus on security and test coverage`).

### `/speckit.implement` (core)
- **Purpose:** Execute the tasks.
- **Input:** Usually none.  
  **Tip:** Implement phase-by-phase for large features.

## 3. General Tips, Tricks & Optimisations

- **Iterate aggressively** — use `/clarify`, `/analyze`, and `/checklist` multiple times. Do **not** manually edit generated files if possible; re-run commands instead.
- **Review every artifact** before moving forward. You are the gatekeeper.
- **Start small** — implement one phase at a time, especially for complex features.
- **Templates & presets** — use `specify template save` and `--template` for reusable project types.
- **Branching strategy** — Spec-kit creates numbered specs and feature branches automatically. Use constitution to enforce your PR workflow.
- **Parallel work** — Spec-kit supports parallel phases; orchestrator agents can handle them on separate branches.
- **Team usage** — Constitution + shared specs work well. Numbered specs can cause minor merge conflicts in large teams — coordinate via issues.
- **Version control** — Commit `.specify/` folder (except cache). It is part of your living documentation.
- **Prompt quality** — Write authoritative, natural-language, detailed prompts. Short vague prompts produce poor results.

## 4. Using Simpler LLMs to Prepare Prompts

**Short answer:** Yes, it makes sense in specific cases, but not as the primary driver.

**When it works well:**
- Use a fast/cheap model (e.g. your local Qwen3, Gemini Flash, Groq small models) to brainstorm, expand, or refine the **initial natural-language description** you will feed into `/speckit.specify` or `/speckit.plan`.
- Example workflow:  
  1. Feed rough idea to simple LLM → get polished, detailed user-story text.  
  2. Copy that text into your strong coding agent + `/speckit.specify`.

**When it does not make sense:**
- Never use a weak model for the actual `/specify`, `/plan`, or `/implement` steps — Spec-Kit’s quality depends heavily on the agent’s reasoning capability.
- Avoid chaining weak models for the full workflow; it defeats the purpose of structured SDD.

**Optimisation tip:** Keep a “prompt-refiner” agent in your OpenCode setup that specialises in turning vague ideas into high-quality spec-kit input text.

## 5. Final Recommendations

1. Always start with a strong constitution.
2. Invest time in the first `/speckit.specify` prompt — it pays off downstream.
3. Treat the workflow as gated and iterative.
4. Review, clarify, analyze — then implement.
5. Use GitHub MCP + branch protection to make the process truly hands-off after the spec is approved.

Spec-Kit turns “vibe coding” into predictable, auditable, high-quality development when you follow these practices.

**References**  
- Official Quickstart & Commands: https://github.github.com/spec-kit/  
- GitHub Spec-Kit repo: https://github.com/github/spec-kit  
- Spec-Driven Development methodology: https://github.com/github/spec-kit/blob/main/spec-driven.md

------------------------------------

# /speckit.taskstoissues – Integration Guide

**Audience:** Future me and fellow developers using the `opencode` + `spec-kit` module from https://github.com/Yury-Zakharov/nix-devshell

## What the command does

`/speckit.taskstoissues` takes the task list generated by `/speckit.tasks` (which lives in `.specify/tasks.md`) and **automatically creates one GitHub Issue per task** (or per phase, depending on how tasks are grouped).

- It uses your existing GitHub MCP (or gh CLI if configured).
- Issues are created in the repository that matches your current Git remote.
- Each issue contains the task description, references the corresponding spec/plan ID, and can be linked back to the feature branch/PR.

The command is **optional** in the spec-kit workflow. It sits between `/speckit.tasks` and `/speckit.implement`.

## How it fits your current setup (single declaration, zero implicit, minimum manual)

**Current workflow (PR-centric):**
- You already have a very clean, gated PR-per-phase process enforced by:
  - Constitution (GitHub Workflow section)
  - Remote GitHub MCP (`create_pull_request`, `review_pr`, `merge_pr`)
  - Branch protection rules + required CI
  - PR template that links to spec/plan

**Adding `/speckit.taskstoissues` would introduce:**
- Parallel artifact: GitHub Issues alongside PRs
- Extra GitHub MCP permission: `issue_write` (very small addition to your existing fine-grained PAT)
- Automatic traceability between tasks → issues → PRs

**Fit assessment:**

**Pros (why it can make sense)**
- Excellent traceability: every task has a permanent GitHub Issue number that can be referenced in code, PRs, commits, and future specs.
- Better visibility for teams or for you when juggling multiple features (GitHub Projects, milestones, labels, burndown).
- Issues can be assigned, commented on, and closed automatically via MCP.
- Constitution can enforce “every task must have a corresponding issue” (add one line).
- Zero extra Nix modules — your existing GitHub MCP already supports it (just needs the `issue_write` scope).

**Cons (why it might not be needed in your setup)**
- Adds a second layer of GitHub objects (Issues + PRs) while your current PR-only flow is already very clean and sufficient for solo or small-team work.
- Slight increase in token usage and MCP calls.
- If you strictly follow phase → branch → PR, the Issues become somewhat redundant (the PR itself already serves as the “task tracker”).
- Extra manual step in the command chain (unless you make the orchestrator agent call it automatically).

**My recommendation for your DAO**

**Skip it for now** (default recommendation).

Your current setup already achieves:
- Full traceability (via spec/plan IDs in PR titles/descriptions)
- Automated PR creation/review/merge
- Strict review gates

Adding Issues would slightly violate the “minimum manual interaction” and “single source of truth” (PRs are already the source of truth).

Only enable `/speckit.taskstoissues` if you:
- Work with a team that heavily uses GitHub Issues / Projects
- Want burndown-style tracking
- Frequently reference individual tasks across multiple PRs

## How to enable it (if you ever decide to)

1. Update your fine-grained PAT to include **Issues → Read and write** permission.
2. Add one line to the GitHub Workflow section in `constitution.md`:
   - After `/speckit.tasks`, the orchestrator must run `/speckit.taskstoissues` to create corresponding GitHub Issues.
3. (Optional) Update the command-agent mapping in your README to include:
   | `/speckit.taskstoissues` | `sisyphus` (Coder) | Convert tasks to GitHub Issues |

No changes to any Nix module required — your existing remote GitHub MCP already supports the `issue_write` tool.

## Final verdict

In your extremely clean, PR-first, spec-driven setup, `/speckit.taskstoissues` is **not essential** and adds mild complexity without proportional value.  
Keep it in your back pocket for projects that require strong issue-based tracking. For everything else, your current constitution + MCP + PR workflow is already optimal.
