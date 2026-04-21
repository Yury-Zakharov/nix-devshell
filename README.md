# nix-devshell

Reusable Nix devshell modules and templates.

**Goal**: every development project gets an isolated, project-root-only environment.  
No global state, no `~/` paths, no implicit behaviour.  
Single declaration site for every module and overlay.

## Create a new project

```bash
nix flake new myproject -t github:Yury-Zakharov/nix-devshell
cd myproject

# Edit flake.nix → uncomment only the modules you need
# (single declaration site for this project)
direnv allow
```

## Update an existing project

```bash
cd myproject
nix flake update devshell   # updates the template + all modules/overlays
direnv allow
```

## Introduce a new module

1. Create `modules/my-new-tool.nix` (must accept `{ pkgs }:` and return `{ packages, env?, shellHook? }`).
2. Add it to the single declaration site in `flake.nix`:
```nix
modules = {
  # ... existing modules
  my-new-tool = import ./modules/my-new-tool.nix;
};
```
3. (Optional) Add an example to `templates/default/flake.nix` in the `extraModules` list.
4. Commit and push.

## Introduce a new overlay

1. Create `overlays/my-overlay.nix` (standard `final: prev: { … }` form).
2. Add it to the single declaration site in `overlays.nix`.
3. Rebuild any test project (`nix flake update devshell && direnv allow`).
------------

All files live inside the project root (`.cache/`, `.config/`, `.local/share/`, `.venv/`, `.nuget/`, `.swarmvault/`, etc.).
The repo is public and designed for GitHub CI/CD (see `packages.default` and `checks.default` in the template).

Made for multi-machine, zero-drift development.
