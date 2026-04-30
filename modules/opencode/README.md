### GitHub Branch Protection Setup (main / master)

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

### Spec-Kit Commands → Recommended Agents

| Command                  | Recommended Agent(s)                          | Order | Parameters                          | Notes |
|--------------------------|-----------------------------------------------|-------|-------------------------------------|-------|
| `/speckit.constitution` | `prometheus` (Architect)                     | 1     | None (free-text prompt optional)   | Rarely needed – your pre-populated constitution is already used |
| `/speckit.specify`      | `prometheus` or `planner` (Architect)       | 2     | None (free-text feature description) | Core command. Provide natural language after the command |
| `/speckit.clarify`      | `oracle` (Architect)                         | 3     | None (free-text clarification)     | Optional – use when spec needs refinement |
| `/speckit.plan`         | `prometheus` → `hephaestus` (Coder)         | 4     | None (free-text tech preferences)  | Core – provide any specific stack hints if wanted |
| `/speckit.tasks`        | `sisyphus` (Coder)                           | 5     | None                               | Core |
| `/speckit.taskstoissues`| `sisyphus` (Coder)                           | 6     | None                               | Optional |
| `/speckit.analyze`      | `momus` (Tester) or `oracle`                 | 7     | None                               | Optional – run before implement |
| `/speckit.implement`    | `hephaestus` or `executor` (Coder)           | 8     | None                               | Core |
| `/speckit.checklist`    | `momus` (Tester)                             | any   | None                               | Flexible – quality gate at any time |


**How to use:**
- Always prefix with the agent: `@prometheus /speckit.specify Create a Facebook clone to run on my laptop so that I earn billions`
- Run commands in the listed order.
- Parallel phases (detected by spec-kit) are automatically assigned by `sisyphus` to separate agents on separate branches.

**Additional thoughts:**
- GitHub MCP tools (`create_pull_request`, `review_pr`, `merge_pr`) are available to **all** agents after constitution is loaded.
- For best results, let the Architect role own specification/planning and the Coder role own implementation.
- Tester role is only for validation/review steps.
