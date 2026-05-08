#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${1:-}"
if [[ -z "$PROJECT_DIR" ]]; then
  PROJECT_DIR=$(gum input --prompt "Project directory (name or full path): " --value "my-project")
fi
PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"

if [[ -d "$PROJECT_DIR" ]]; then
  echo "Error: '$PROJECT_DIR' already exists"
  exit 1
fi

nix flake new "$PROJECT_DIR" -t github:Yury-Zakharov/nix-devshell
cd "$PROJECT_DIR"

# Presets
mapfile -t PRESET_KEYS < <(nix eval --impure --json --expr 'builtins.attrNames ((builtins.getFlake "github:Yury-Zakharov/nix-devshell").presets)' | jq -r '.[]' | sort)
PRESET=$(gum choose --header "Choose a preset" "${PRESET_KEYS[@]}")

# Load preset modules
if [[ "$PRESET" == "minimal" ]]; then
  mapfile -t PRESET_MODULES < <(echo -n "")
else
  mapfile -t PRESET_MODULES < <(nix eval --impure --json --expr '((builtins.getFlake "github:Yury-Zakharov/nix-devshell").presets."'"$PRESET"'")' | jq -r '.[]')
fi

# Module descriptions
mapfile -t DESCS < <(nix eval --impure --json --expr '((builtins.getFlake "github:Yury-Zakharov/nix-devshell").moduleDescriptions)' | jq -r 'to_entries[] | "\(.key) - \(.value)"' | sort)

mapfile -t OPTIONAL < <(printf '%s\n' "${DESCS[@]}" | grep -v '^base - ')

# Build pre-selected strings (exact match for gum --selected)
mapfile -t SELECTED_PRE < <(for m in "${PRESET_MODULES[@]}"; do
  for d in "${DESCS[@]}"; do
    if [[ "$d" == "$m - "* ]]; then echo "$d"; break; fi
  done
done)

SELECTED=$(gum choose --no-limit --ordered --selected "${SELECTED_PRE[@]}" --header "Additional modules (preset pre-selected)" "${OPTIONAL[@]}")

EXTRA_MODULES=(base)
if [[ -n "$SELECTED" ]]; then
  mapfile -t SEL <<< "$SELECTED"
  for s in "${SEL[@]}"; do
    MODULE="${s%% - *}"
    [[ ! " ${EXTRA_MODULES[*]} " =~ " ${MODULE} " ]] && EXTRA_MODULES+=("$MODULE")
  done
fi

# Ensure preset modules are present
for m in "${PRESET_MODULES[@]}"; do
  [[ ! " ${EXTRA_MODULES[*]} " =~ " ${m} " ]] && EXTRA_MODULES+=("$m")
done

# Copy template + replace block
TEMPLATE_PATH=$(nix eval --impure --raw --expr '(builtins.getFlake "github:Yury-Zakharov/nix-devshell").templates.default.path')
cp "$TEMPLATE_PATH/flake.nix" flake.nix

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
echo "   Preset : $PRESET"
echo "   Modules: ${EXTRA_MODULES[*]}"
echo "   Next   : direnv allow"
