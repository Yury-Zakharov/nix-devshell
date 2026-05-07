#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${1:-}"
if [[ -z "$PROJECT_DIR" ]]; then
  PROJECT_DIR=$(gum input --prompt "Project directory (name or full path): " --value "my-project")
fi
if [[ -d "$PROJECT_DIR" ]]; then
  echo "Error: $PROJECT_DIR already exists"
  exit 1
fi

nix flake new "$PROJECT_DIR" -t github:Yury-Zakharov/nix-devshell
cd "$PROJECT_DIR"

# Dynamic modules from the flake (single source of truth)
mapfile -t ALL_MODULES < <(nix eval --json --expr 'builtins.attrNames ((builtins.getFlake "github:Yury-Zakharov/nix-devshell").modules)' | jq -r '.[]' | sort)

# Multi-select (base forced)
mapfile -t OPTIONAL < <(printf '%s\n' "$$   {ALL_MODULES[@]}" | grep -v '^base   $$')
SELECTED=$$   (gum choose --no-limit --ordered --header "Select additional modules (base is always included)" "   $${OPTIONAL[@]}")

EXTRA_MODULES=(base)
if [[ -n "$SELECTED" ]]; then
  mapfile -t SEL <<< "$SELECTED"
  EXTRA_MODULES+=("${SEL[@]}")
fi

# Re-copy template + inject exact extraModules block (preserves template as source of truth)
TEMPLATE_PATH=$(nix eval --raw --expr '(builtins.getFlake "github:Yury-Zakharov/nix-devshell").templates.default.path')
cp "$TEMPLATE_PATH/flake.nix" flake.nix

# Replace block cleanly
NEW_BLOCK=$(cat <<EOT
      # Single declaration site for this project's modules
      extraModules = [
        devshell.modules.base
EOT
)
for m in "${EXTRA_MODULES[@]:1}"; do
  NEW_BLOCK+=$$   '\n        devshell.modules.'"   $${m}"
done
NEW_BLOCK+=$'\n        # ... add/remove only here\n      ];'

sed -i "/# Single declaration site for this project's modules/,/^\s*];/c\\${NEW_BLOCK}" flake.nix

# .gitignore + git init
cat > .gitignore << 'EOF'
/result
.direnv/
.vscode/
.idea/
__pycache__/
node_modules/
.DS_Store
