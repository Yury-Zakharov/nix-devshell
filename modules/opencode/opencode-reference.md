# OpenCode Setup – Complete Reference

**Repository:** https://github.com/Yury-Zakharov/nix-devshell  
**Last updated:** May 2026

## 1. Core Principles (DAO)

- Single owner – every moving part belongs to exactly one Nix module.
- Single declaration site – configuration lives in the repo (never generated or scattered).
- Zero implicit behavior – everything is explicit, version-controlled, and reproducible.

## 2. High-Level Architecture

The setup combines:
- OpenCode core + oh-my-openagent + micode plugins
- Spec-kit (official GitHub SDD toolkit)
- Remote GitHub MCP for automatic PR creation, review, and merge
- GitHub branch protection + CI + PR template (pre-copied)

## 3. Providers & Models

Clean, ordered provider block in `modules/opencode/default.jsonc`:
- Free-first ordering in `/models` list
- Per-role fallback chains (Architect / Coder / Tester)
- Local Qwen3 30B is the final free safety net
- GLM-5 series uses your paid quarterly subscription
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

## 5. Spec-Kit Integration (updated)

- Pre-configured via `modules/spec-kit.nix`
- spec-kit keeps its own default constitution template
- Our custom constitution is copied to the project root as `constitution-example.md`
- GitHub workflow files (CI, PR template) and `best-practices.md` are copied automatically on first run
- **You must manually run `/speckit.constitution`** once per project to apply the custom constitution

## 6. GitHub Integration

- Remote GitHub MCP (`https://api.githubcopilot.com/mcp/`) with fine-grained PAT
- Agents can auto-create PRs, request reviews, and merge
- Branch protection + required CI checks + PR template enforced
- Constitution defines exact branch naming and PR flow

## 7. How to Use (Step-by-Step)

1. Add modules in your project’s `flake.nix`:
   ```nix
   devshell.modules = [ "opencode" "spec-kit" "git-worktree" "github-mcp" ];
   ```

2. Set required environment variables in `.envrc` (GITHUB_TOKEN, ZAI_API_KEY, etc.)

3. `direnv allow`

**Recommended workflow (fresh session after each major step):**
- Open a fresh OpenCode session
- `@prometheus /speckit.specify`
- (Optional) `@prometheus /speckit.clarify`
- `@prometheus /speckit.plan`
- `@sisyphus /speckit.tasks`
- **Run `/speckit.constitution` once** (applies your custom constitution)
- `@hephaestus /speckit.implement` (or preferred coder agent)

**Important:** For best stability and to avoid context/compaction issues, start a **new OpenCode session** after each major spec-kit command (`specify`, `plan`, `tasks`, `implement`).

**Typical workflow example**

```bash
@prometheus /speckit.specify Add user authentication with GitHub OAuth
```

→ Agent creates `spec.md`  
→ `@prometheus /speckit.plan` → creates technical `plan.md`  
→ `@sisyphus /speckit.tasks` → breaks into phases  
→ `@hephaestus /speckit.implement` → implements on feature branch  
→ Agent uses GitHub MCP to create PR, request review, and merge after approval

## 8. Command → Agent Mapping

| Command                | Recommended Agent          | Purpose                     |
|------------------------|----------------------------|-----------------------------|
| `/speckit.specify`     | `prometheus` / `planner`   | Raw idea → spec            |
| `/speckit.clarify`     | `prometheus` / `oracle`    | Resolve ambiguities        |
| `/speckit.plan`        | `prometheus` → `hephaestus`| Technical plan             |
| `/speckit.tasks`       | `sisyphus`                 | Task breakdown             |
| `/speckit.implement`   | `hephaestus` / `executor`  | Implementation             |
| `/speckit.constitution`| `prometheus`               | Apply custom constitution  |

## 9. Maintenance & Extensibility

- All defaults live in `modules/opencode/` and `modules/spec-kit/`
- Changes are made once in the nix-devshell repo
- Every project inherits the exact same reproducible environment
- To add a new agent/role/model: edit the single declaration file and rebuild

This document lives in the nix-devshell repository and is copied into every project that uses the `opencode` module.

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


# Git Worktree Usage Guide – Human vs Agent Responsibilities & Walk-through

**Module:** `git-worktree.nix` (optional)  
**Purpose:** Enable true parallel development with spec-kit phases without branch-switching conflicts.

## 4. Human vs Agent Responsibilities (unambiguous)

| Action                              | Who does it          | How / Command                                      | Notes |
|-------------------------------------|----------------------|----------------------------------------------------|-------|
| Run spec-kit commands (`/speckit.*`) | **Agent**            | `@sisyphus /speckit.tasks` etc.                   | Agent executes inside current worktree |
| Create new worktree for a phase     | **You (human)**      | `wt-phase 005` or `wt-create feature/phase-005-…` | Manual one-time action |
| Switch between worktrees            | **You (human)**      | `cd ../project-feature-phase-005-…`                | Manual |
| Run implementation in a worktree    | **Agent**            | `@hephaestus /speckit.implement` (inside worktree) | Agent works in its own isolated directory |
| Create PR / review / merge          | **Agent**            | GitHub MCP tools (automatic after implement)       | Agent uses MCP |
| Decide which phases run in parallel | **You (human)**      | Run `wt-phase X` for each phase you want parallel  | You control parallelism |
| Delete worktree after merge         | **You (human)**      | `git worktree remove <path>` or `wt-prune`        | Cleanup |

**Core rule:**  
You own the workspace layout (creating and switching worktrees).  
The agent owns all coding, spec-kit commands, and GitHub MCP actions **inside** the worktree you open.

## 5. Concrete Walk-through (made-up case)

**Feature:** “Add dark mode toggle to the photo album app”

1. **You (in main directory)**  
   `@prometheus /speckit.specify Add dark mode toggle with system preference detection`

2. **You**  
   `@prometheus /speckit.plan`  
   `@sisyphus /speckit.tasks`  
   (spec-kit now shows 3 phases: 005-ui-toggle, 006-theme-engine, 007-persistence)

3. **You decide parallelism** (manual)  
```bash
wt-phase 005
cd ../photoalbum-feature-phase-005-ui-toggle
```

4. **Agent** (inside the new worktree)  
```bash
@hephaestus /speckit.implement
```

5. **You** (back in main directory)  
```bash
cd ../photoalbum                  # return to main working directory
wt-phase 006
cd ../photoalbum-feature-phase-006-theme-engine
@hephaestus /speckit.implement
```

**Repeat** steps 4–5 for every parallel phase (007, etc.).

6. **Agent** (in each worktree)  
   After implementation finishes, the agent automatically creates the PR via GitHub MCP.

7. **You** (cleanup after PR merge)  
```bash
cd ../photoalbum   # back to main
git worktree remove ../photoalbum-feature-phase-005-ui-toggle
```

This keeps your DAO intact: **you** control the workspace, **agents** control the coding and GitHub actions.

Copy this document into your nix-devshell repo or project documentation.

This document lives in the nix-devshell repository and is copied into every project that uses the `opencode` module.

You now have a clean, controllable, spec-first development environment that follows your principles to the letter.
