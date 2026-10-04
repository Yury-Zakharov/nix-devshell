# Spec-kit + Pocock skills — one workflow

This file is the operating procedure. Constitution states ownership.
`AGENTS.md` binds the agent to this file. Spec-kit still owns artifacts.

Spec-kit commands do not load Pocock skills on their own. The agent must
invoke the named skill **before** writing or changing a spec-kit artifact.
If a required skill is missing, stop and say so. Do not improvise the grill.

## Binding rule (agent)

On any `/speckit.*` invocation:

1. Read this file and the constitution.
2. Load the skill listed for that phase (OpenCode `skill` tool / `/skill-name`).
3. Interrogate the human until the phase exit criteria are met.
4. Only then write spec-kit artifacts under `.specify/` / `specs/`.
5. Do not use `/to-spec`, `/to-tickets`, or skills `/implement` as the pipeline.

If the human only typed `/speckit.specify` (or any other spec-kit command)
with no extra text, still run the grill for that phase first.

---

## Once per project

Already done if setup ran. If not:

1. `/setup-matt-pocock-skills` — tracker + labels + domain doc paths only.
2. `/speckit.constitution` — paste the block from
   `matt-pocock-skills-constitution-fragment.md`.
3. Paste the block from `matt-pocock-skills-agents-fragment.md` into `AGENTS.md`.

Do not re-run these every feature.

---

## Per feature — full path

Use this for anything that will live in the codebase. One feature, one pass
through the chain. Do not start `/speckit.implement` with an ungrilled spec.

### 1. Specify — `/speckit.specify`

**Load first:** `/grill-me`. If `CONTEXT.md` or `docs/adr/` already exists,
load `/grill-with-docs` instead (or as well).

**Grill until:** every branch of the decision tree is resolved: who, what,
why, out of scope, failure cases, acceptance. No “we’ll decide later”
left in the spec body unless explicitly parked as an open question.

**Then:** write the spec-kit specification only.

**Do not:** call `/to-spec`. That is not the system of record.

### 2. Clarify — `/speckit.clarify`

**Load first:** `/grilling` (the reusable loop behind grill-me).

**Grill until:** each ambiguity spec-kit surfaces has a human answer or a
documented deferral.

**Then:** fold answers back into the spec-kit spec.

Skip this phase only when the spec has no unresolved branches. If you skip,
say so in one sentence.

### 3. Domain language (not a spec-kit command)

**Load:** `/domain-modeling`.

**When:** after specify/clarify, before plan, whenever new terms appeared.

**Then:** update `CONTEXT.md` and ADRs. These are additive to spec-kit
artifacts, not a replacement.

### 4. Plan — `/speckit.plan`

**Load first:** `/codebase-design`. On an existing codebase also load
`/improve-codebase-architecture` and grill the deepening choice.

**Grill until:** module boundaries, seams, tech choices, and “what we will
not build” are explicit.

**Then:** write the spec-kit plan. Architecture lives here, not in the spec.

### 5. Checklist — `/speckit.checklist`

No Pocock skill. Spec-kit checks the spec itself.

If the checklist exposes a product ambiguity, go back to step 2 (`/grilling`),
do not invent the answer in the checklist.

### 6. Tasks — `/speckit.tasks`

No Pocock skill. One backlog: spec-kit tasks.

**Do not:** run `/to-tickets` unless the human explicitly wants tracker
mirrors. Spec-kit tasks remain authoritative.

Mark TDD seams on implementation tasks (the interfaces `/tdd` will hit).

### 7. Analyze — `/speckit.analyze`

No Pocock skill. Consistency gate across spec, plan, tasks.

If analyze reports a product hole, return to specify/clarify + grill.
If it reports a design hole, return to plan + `/codebase-design`.

### 8. Implement — `/speckit.implement`

**Load per seam:** `/tdd` (red → green → refactor). Vertical slices only.

**Do not:** use skills `/implement` as the outer loop.

If a task is a hard bug rather than new behavior, load `/diagnosing-bugs`
instead of guessing a patch.

### 9. Converge — `/speckit.converge`

**Load first:** `/code-review` (Standards axis and Spec axis, separately).

**Then:** spec-kit converge. Repeat implement → review → converge until
spec-kit reports converged.

---

## Per feature — short path

Tiny, low-ambiguity change only:

`/grill-me` → `/speckit.specify` → `/speckit.plan` → `/speckit.tasks` →
`/speckit.implement` (with `/tdd`) → `/code-review` → `/speckit.converge`

If the grill produces more than two unresolved branches, switch to the
full path and run `/speckit.clarify`.

---

## Bugs (existing behavior broken)

Do not open with `/speckit.implement`.

1. `/diagnosing-bugs` (reproduce → minimise → hypothesise → instrument → fix).
2. If the fix needs a spec change: `/grill-me` then `/speckit.specify` on
   the delta, then the normal chain from plan.
3. `/code-review` before merge.

---

## Phase cheat sheet

| You type | Agent loads first | Exit when | Writes |
| --- | --- | --- | --- |
| `/speckit.specify` | `/grill-me` or `/grill-with-docs` | Decision tree closed | spec-kit spec |
| `/speckit.clarify` | `/grilling` | Each ambiguity answered | spec updated |
| (no speckit cmd) | `/domain-modeling` | Glossary + ADRs match the spec | `CONTEXT.md`, `docs/adr/` |
| `/speckit.plan` | `/codebase-design` (+ architecture skill if brownfield) | Seams and stack decided | spec-kit plan |
| `/speckit.checklist` | — | Spec quality checked | checklist |
| `/speckit.tasks` | — | Tasks + TDD seams listed | spec-kit tasks |
| `/speckit.analyze` | — | Artifacts consistent | analysis |
| `/speckit.implement` | `/tdd` at each seam | Tests + code for the slice | code |
| `/speckit.converge` | `/code-review` | Spec and standards both pass | converge report |

---

## Human checklist (one feature)

- [ ] Grill finished before the spec was written
- [ ] Spec-kit spec / plan / tasks exist (not only chat)
- [ ] `CONTEXT.md` updated if terms changed
- [ ] Tasks name the TDD seams
- [ ] Implementation used `/tdd`, not a one-shot dump
- [ ] `/code-review` ran before converge was accepted
- [ ] Skills `/implement`, `/to-spec`, `/to-tickets` were not the pipeline
