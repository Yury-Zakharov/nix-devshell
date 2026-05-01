# OpenCode Setup – Complete Reference

**Repository:** https://github.com/Yury-Zakharov/nix-devshell  
**Last updated:** May 2026

## 1. Core Principles (DAO)

This devshell is built on three non-negotiable rules:

- Single owner – every moving part belongs to exactly one Nix module.
- Single declaration site – configuration lives in the repo (never generated or scattered).
- Zero implicit behavior – everything is explicit, version-controlled, and reproducible.

## 2. High-Level Architecture

The setup combines:
- OpenCode core + oh-my-openagent + micode plugins
- Spec-kit (official GitHub SDD toolkit) with custom immutable constitution
- Remote GitHub MCP for automatic PR creation, review, and merge
- GitHub branch protection + CI + PR template (pre-copied)

All configuration is copied on first shell entry (copy-on-first-run pattern in Nix `shellHook`).

## 3. Providers & Models

Clean, ordered provider block in `modules/opencode/default.jsonc`:
- Free-first ordering in `/models` list
- Per-role fallback chains (Architect / Coder / Tester)
- Local Qwen3 30B is the final free safety net (never first)
- GLM-5 series uses your paid quarterly subscription (correct `zai` baseURL)
- All models have short, distinct human-readable names

## 4. Agent Roles & Configuration

All agents are explicitly mapped to three roles in:
- `modules/opencode/default-oh-my-openagent.jsonc`
- `modules/opencode/default-micode.json`

**Roles**
- Architect (`prometheus`, `oracle`, `librarian`, `explore`, `brainstormer`, `planner`) – temperature 0.1
- Coder (`sisyphus`, `hephaestus`, `sisyphus-junior`, `commander`, `executor`, `implementer`) – temperature 0.25
- Tester (`momus`, `metis`, `atlas`, `reviewer`) – temperature 0.1

Each role has its own free-first fallback chain ending with GLM subscription → local model.

## 5. Spec-Kit Integration

- Pre-configured via `modules/spec-kit.nix`
- Custom `constitution.md` (functional style, no implicit state, pure total functions, TDD + readonly tests, strict GitHub workflow)
- GitHub workflow files (CI, PR template) copied automatically
- `/speckit.constitution` is **not** needed — constitution is already loaded

## 6. GitHub Integration

- Remote GitHub MCP (`https://api.githubcopilot.com/mcp/`) with fine-grained PAT
- Agents can auto-create PRs, request reviews, and merge
- Branch protection + required CI checks + PR template enforced
- Constitution defines exact branch naming and PR flow

## 7. How to Use (Step-by-Step)

1. Add modules in your project’s `flake.nix`:
   ```nix
      extraModules = [
        devshell.modules.base
        devshell.modules.spec-kit
        devshell.modules.opencode
        # devshell.modules.dotnet
        # ... add/remove only here
      ];
   ```

2. Set `GITHUB_MCP_PAT` in `.envrc` (fine-grained PAT with repo + pull_request + workflow scopes).

3. `direnv allow` → everything is auto-initialised.

**Typical workflow example**

```bash
@prometheus /speckit.specify Add user authentication with GitHub OAuth
```

→ Agent creates `spec.md` (tech-agnostic)  
→ `@prometheus /speckit.plan` → creates technical `plan.md`  
→ `@sisyphus /speckit.tasks` → breaks into phases  
→ `@hephaestus /speckit.implement` → implements on feature branch  
→ Agent uses GitHub MCP to create PR, request review, and merge after approval

## 8. Spec-Kit Commands → Recommended Agents

| Command                  | Recommended Agent(s)                          | Order | Parameters                          | Notes |
|--------------------------|-----------------------------------------------|-------|-------------------------------------|-------|
| `/speckit.constitution` | `prometheus` (Architect)                     | 1     | (free-text prompt optional)   | Rarely needed – your pre-populated constitution is already used |
| `/speckit.specify`      | `prometheus` or `planner` (Architect)       | 2     | (free-text feature description) | Core command. Provide natural language after the command |
| `/speckit.clarify`      | `oracle` (Architect)                         | 3     | (free-text clarification)     | Optional – use when spec needs refinement |
| `/speckit.plan`         | `prometheus` → `hephaestus` (Coder)         | 4     | (free-text tech preferences)  | Core – provide any specific stack hints if wanted |
| `/speckit.tasks`        | `sisyphus` (Coder)                           | 5     | None                               | Core |
| `/speckit.taskstoissues`| `sisyphus` (Coder)                           | 6     | None                               | Optional |
| `/speckit.analyze`      | `momus` (Tester) or `oracle`                 | 7     | None                               | Optional – run before implement |
| `/speckit.implement`    | `hephaestus` or `executor` (Coder)           | 8     | None                               | Core |
| `/speckit.checklist`    | `momus` (Tester)                             | any   | None                               | Flexible – quality gate at any time |


## 9. Maintenance & Extensibility

- All defaults live in `modules/opencode/` and `modules/spec-kit/`
- Changes are made once in the nix-devshell repo
- Every project inherits the exact same reproducible environment
- To add a new agent/role/model: edit the single declaration file and rebuild

## 10. GitHub Branch Protection Setup (main / master)

1. Go to your repository → **Settings** → **Branches** (left sidebar).
2. Under **Branch protection rules** click **Add branch protection rule**.
3. In **Branch name pattern** enter: `main`  
   (use `master` if that is your default branch name).
4. Enable the following options:

   - **Require a pull request before merging**  
     - Require approvals: **1**
   - **Require status checks to pass before merging**  
     - Check **Require branches to be up to date before merging**  
     - Select the `CI` workflow in the list of required checks
   - **Do not allow bypassing the above settings**
   - **Require linear history** (recommended)
   - **Do not allow force pushes**
   - **Do not allow deletions**

5. Click **Create** (or **Save changes**).

Once enabled, GitHub will automatically enforce the CI/CD rules defined in the project constitution.

This document lives in the nix-devshell repository and is copied into every project that uses the `opencode` module.

You now have a clean, controllable, spec-first development environment that follows your principles to the letter.
