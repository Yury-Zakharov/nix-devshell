# Matt Pocock skills — constitution fragment

Paste the block below into the project constitution (`/speckit.constitution`).
Do not apply it automatically. Spec-kit stays the process owner.

## Process ownership

- Spec-kit owns the pipeline and the durable artifacts:
  constitution, specify, plan, tasks, implement, analyze, converge.
  Commands: `/speckit.*`. Artifacts: `.specify/`, `specs/`.
- Oh-my-openagent (OMO) owns model routing, fallbacks, and named agents.
  Config: `.opencode/oh-my-openagent.jsonc`. Do not add Pocock skills as OMO agents.
- Matt Pocock skills own engineering discipline inside those phases.
  Files: `.opencode/matt-pocock-skills/`. Discovery: symlinks under `.opencode/skills/`.

## Phase mapping

| When | Use | Do not use as the pipeline |
| --- | --- | --- |
| Clarify assumptions / domain language | `/grill-me`, `/grill-with-docs`, `/domain-modeling` | — |
| Write or refresh CONTEXT.md and ADRs | `/domain-modeling`, `/grill-with-docs` | — |
| TDD at an agreed seam | `/tdd` during `/speckit.implement` | — |
| Review against standards and the originating spec | `/code-review` after implement / at converge | — |
| Deepen existing modules | `/codebase-design`, `/improve-codebase-architecture` | — |
| Diagnose a hard bug | `/diagnosing-bugs` | — |
| Turn a conversation into spec-kit input | `/grill-me` then `/speckit.specify` | `/to-spec` as the system of record |
| Implementation | `/speckit.implement` (may drive `/tdd` + `/code-review`) | Skills `/implement` as the outer loop |

## Backlog

One backlog: spec-kit tasks. `/setup-matt-pocock-skills` may record tracker
and label conventions only. It must not replace spec-kit tasks.

## TDD

TDD is required at pre-agreed seams. Tests are necessary and not sufficient
for correctness. Domain model, architecture hygiene, and two-axis code review
are also required.

## First run

Once per repo, in OpenCode: `/setup-matt-pocock-skills`.
Prefer GitHub or local files. Domain docs: `CONTEXT.md` + `docs/adr/`.
Those are additive to spec-kit artifacts.
