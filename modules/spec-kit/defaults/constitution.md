# Project Constitution

## Core Principles
- Spec-Driven Development (SDD) is mandatory.
- Every feature starts with a spec before any code or plan.
- Separation of concerns is strict and non-negotiable.

## Documentation Rules
- **spec.md** (WHAT & WHY) – technology-agnostic, business-focused.
  - Only user stories, requirements, success criteria, acceptance conditions.
  - No implementation details, no tech terms (except pure domain language).
  - Target audience: Product Owner, stakeholders, domain experts.
- **plan.md** (HOW) – technical implementation.
  - All architecture, frameworks, libraries, code decisions.
  - Constitution checks and complexity notes belong here.
- Violation of separation blocks merge.

## Development Rules
- Strict functional-first approach is mandatory:
  - Prefer immutable data structures.
  - Use function composition and higher-order functions.
  - Eliminate nulls; use Option<T> (or equivalent) instead.
  - Use Either<Error, T> (or equivalent) instead of exceptions.
- Additional functional & type-safe design principles:
  - No implicit state: all state must be explicit and passed as parameters.
  - Prefer stateless designs wherever possible.
  - Make invalid states irrepresentable in the type system.
  - Prefer pure total functions that are deterministic and always produce a valid output for every input.
- Strict TDD:
  - Tests written for a phase/task are readonly for all future phases.
  - Later implementation must not modify or delete existing tests.
  - New tests may only be added; existing ones must continue to pass.
- All changes must be traceable to a spec.

## GitHub Workflow & Collaboration (mandatory CI/CD)
- Main branch (`main` or `master`) is the single source of truth. It must always build, pass tests, and be deployable.
- Never commit or push directly to main.
- Branch protection rules on `main` (enforced in GitHub settings):
  - Require at least 1 review approval.
  - Require status checks to pass (CI must succeed).
  - Do not allow force-push or direct commits.
- Every specification and every implementation phase follows the same strict flow:
  1. Always start from the latest main.
  2. Create a short-lived feature branch named `feature/phase-XXX-short-name` (XXX = phase number from spec-kit).
  3. Complete all work on that branch only.
  4. Agents use GitHub MCP tools to automatically create a PR with correct title format, spec/plan reference, and checklist.
  5. Request review (human or designated agent).
  6. Fix review comments in the same branch (loop until approved).
  7. Merge PR to main (squash merge only).
  8. Delete the feature branch locally and remotely.
- Parallel phases must each get their own independent feature branch. Orchestrator agent assigns them to separate agents.
- All PRs must use the project PR template and reference the corresponding spec/plan ID.
- Conventional commits are mandatory for all commit messages.

This constitution is immutable for the lifetime of the project.
