# nix-devshell

Reusable Nix devshell modules and templates.

## Create a new project
```bash
nix flake new myproject -t github:Yury-Zakharov/nix-devshell
cd myproject
# edit flake.nix → choose modules
direnv allow
```

All modules live in `modules/` — single declaration site.
No secrets, no implicit paths.
