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

# Preset selection (Custom always first)
mapfile -t PRESET_KEYS < <(nix eval --impure --json --expr 'builtins.attrNames ((builtins.getFlake "github:Yury-Zakharov/nix-devshell").presets)' | jq -r '.[]' | sort)
PRESET_KEYS=("Custom" "${PRESET_KEYS[@]}")
PRESET=$(gum choose --header "Choose a preset or Custom" "${PRESET_KEYS[@]}")

if [[ "$PRESET" == "Custom" ]]; then
  PRESET_MODULES=()
else
  mapfile -t PRESET_MODULES < <(nix eval --impure --json --expr '((builtins.getFlake "github:Yury-Zakharov/nix-devshell").presets."'"$PRESET"'")' | jq -r '.[]' 2>/dev/null || true)
fi

# Descriptions for selector
mapfile -t DESCS < <(nix eval --impure --json --expr '((builtins.getFlake "github:Yury-Zakharov/nix-devshell").moduleDescriptions)' | jq -r 'to_entries[] | "\(.key) - \(.value)"' | sort)
mapfile -t OPTIONAL < <(printf '%s\n' "${DESCS[@]}" | grep -v '^base - ')

# Pre-select using safe --selected= syntax (fixes gum space/hyphen parsing)
SELECTED_ARGS=()
for m in "${PRESET_MODULES[@]}"; do
  for d in "${DESCS[@]}"; do
    if [[ "$d" == "$m - "* ]]; then
      SELECTED_ARGS+=("--selected=$d")
      break
    fi
  done
done

if [[ ${#SELECTED_ARGS[@]} -gt 0 ]]; then
  SELECTED=$(gum choose --no-limit --ordered "${SELECTED_ARGS[@]}" --header "Additional modules (preset pre-selected)" "${OPTIONAL[@]}")
else
  SELECTED=$(gum choose --no-limit --ordered --header "Select additional modules (base is always included)" "${OPTIONAL[@]}")
fi

# Build final list
EXTRA_MODULES=(base)

contains() {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

if [[ -n "$SELECTED" ]]; then
  mapfile -t SEL <<< "$SELECTED"
  for s in "${SEL[@]}"; do
    MODULE="${s%% - *}"
    contains "$MODULE" "${EXTRA_MODULES[@]}" || EXTRA_MODULES+=("$MODULE")
  done
fi

for m in "${PRESET_MODULES[@]}"; do
  contains "$m" "${EXTRA_MODULES[@]}" || EXTRA_MODULES+=("$m")
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
echo "   Next   : nix develop"
