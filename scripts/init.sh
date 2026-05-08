#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${1:-}"
if [[ -z "$PROJECT_DIR" ]]; then
  PROJECT_DIR=$(gum input --prompt "Project directory (name or full path): " --value "my-project")
fi

# Expand ~ if user typed it
PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"

if [[ -d "$PROJECT_DIR" ]]; then
  echo "Error: '$PROJECT_DIR' already exists"
  exit 1
fi

nix flake new "$PROJECT_DIR" -t github:Yury-Zakharov/nix-devshell
cd "$PROJECT_DIR"

# Dynamic modules (works from both local and github reference)
mapfile -t ALL_MODULES < <(nix eval --impure --json --expr 'builtins.attrNames ((builtins.getFlake "github:Yury-Zakharov/nix-devshell").modules)' | jq -r '.[]' | sort)

mapfile -t OPTIONAL < <(printf '%s\n' "${ALL_MODULES[@]}" | grep -v '^base$')
SELECTED=$(gum choose --no-limit --ordered --header "Select additional modules (base is always included)" "${OPTIONAL[@]}")

EXTRA_MODULES=(base)
[[ -n "$SELECTED" ]] && mapfile -t SEL <<< "$SELECTED" && EXTRA_MODULES+=("${SEL[@]}")

# Copy template
TEMPLATE_PATH=$(nix eval --impure --raw --expr '(builtins.getFlake "github:Yury-Zakharov/nix-devshell").templates.default.path')
cp "$TEMPLATE_PATH/flake.nix" flake.nix

# Replace block cleanly (using temp file to avoid sed quoting hell)
cat > /tmp/extra.nix << EOF
      # Single declaration site for this project's modules
      extraModules = [
        devshell.modules.base
$(for m in "${EXTRA_MODULES[@]:1}"; do printf "        devshell.modules.%s\n" "$m"; done)
        # ... add/remove only here
      ];
EOF

sed -i '/# Single declaration site for this project'\''s modules/,/^\s*];/d' flake.nix
sed -i '/^    let$/r /tmp/extra.nix' flake.nix
rm -f /tmp/extra.nix

cat > .gitignore << 'EOF'
/result
.direnv/
.vscode/
.idea/
__pycache__/
node_modules/
.DS_Store
EOF

git init -q
git add flake.nix .envrc .gitignore

echo "✅ Project ready at $(pwd)"
echo "   Modules: ${EXTRA_MODULES[*]}"
echo "   Next: nix develop"
