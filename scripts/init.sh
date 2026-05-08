#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
PRESET=""
DESCRIPTION=""
PROJECT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --preset)
      PRESET="$2"
      shift 2
      ;;
    --description)
      DESCRIPTION="$2"
      shift 2
      ;;
    *)
      if [[ -z "$PROJECT_DIR" ]]; then
        PROJECT_DIR="$1"
      else
        echo "Error: too many arguments" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ -z "$PROJECT_DIR" ]]; then
  if [[ $DRY_RUN -eq 1 || -n "$PRESET" || -n "$DESCRIPTION" ]]; then
    echo "Error: PROJECT_DIR required in non-interactive mode" >&2
    exit 1
  fi
  PROJECT_DIR=$(gum input --prompt "Project directory (name or full path): " --value "my-project")
fi

PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"

if [[ -d "$PROJECT_DIR" ]]; then
  echo "Error: '$PROJECT_DIR' already exists" >&2
  exit 1
fi

# Interactive prompts only when no flags provided
if [[ $DRY_RUN -eq 0 && -z "$PRESET" && -z "$DESCRIPTION" ]]; then
  DESCRIPTION=$(gum input --prompt "Project description (short): " --value "")
  mapfile -t PRESET_KEYS < <(nix eval --impure --json --expr 'builtins.attrNames ((builtins.getFlake "github:Yury-Zakharov/nix-devshell").presets)' | jq -r '.[]' | sort)
  PRESET_KEYS=("Custom" "${PRESET_KEYS[@]}")
  PRESET=$(gum choose --header "Choose a preset or Custom" "${PRESET_KEYS[@]}")
fi

if [[ "$PRESET" == "Custom" || -z "$PRESET" ]]; then
  PRESET_MODULES=()
else
  mapfile -t PRESET_MODULES < <(nix eval --impure --json --expr '((builtins.getFlake "github:Yury-Zakharov/nix-devshell").presets."'"$PRESET"'")' | jq -r '.[]' 2>/dev/null || true)
fi

# Module selection (skipped in non-interactive)
if [[ $DRY_RUN -eq 0 && -z "$PRESET" && -z "$DESCRIPTION" ]]; then
  mapfile -t DESCS < <(nix eval --impure --json --expr '((builtins.getFlake "github:Yury-Zakharov/nix-devshell").moduleDescriptions)' | jq -r 'to_entries[] | "\(.key) - \(.value)"' | sort)
  mapfile -t OPTIONAL < <(printf '%s\n' "${DESCS[@]}" | grep -v '^base - ')
  SELECTED=$(gum choose --no-limit --ordered --header "Additional modules (base is always included)" "${OPTIONAL[@]}")
else
  SELECTED=""
fi

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

if [[ $DRY_RUN -eq 1 ]]; then
  echo "=== DRY RUN ==="
  echo "Project dir : $PROJECT_DIR"
  echo "Preset      : ${PRESET:-Custom}"
  echo "Description : ${DESCRIPTION:-<none>}"
  echo "Modules     : ${EXTRA_MODULES[*]}"
  echo ""
  echo "Would write in flake.nix:"
  cat << EOF
      # Single declaration site for this project's modules
      extraModules = [
        devshell.modules.base
$(for m in "${EXTRA_MODULES[@]:1}"; do printf "        devshell.modules.%s\n" "$m"; done)
        # ... add/remove only here
      ];
      description = "${DESCRIPTION}";
EOF
  exit 0
fi

# Create project
nix flake new "$PROJECT_DIR" -t github:Yury-Zakharov/nix-devshell
cd "$PROJECT_DIR"

TEMPLATE_PATH=$(nix eval --impure --raw --expr '(builtins.getFlake "github:Yury-Zakharov/nix-devshell").templates.default.path')
cp "$TEMPLATE_PATH/flake.nix" flake.nix

cat > /tmp/extra.nix << EOF
      # Single declaration site for this project's modules
      extraModules = [
        devshell.modules.base
$(for m in "${EXTRA_MODULES[@]:1}"; do printf "        devshell.modules.%s\n" "$m"; done)
        # ... add/remove only here
      ];
      description = "${DESCRIPTION}";
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
.stack/
.cache/
.config/
.dotnet/
.local/
.nuget/
.opencode/
EOF

git init -q
git add flake.nix .envrc .gitignore

echo "✅ Project ready at $(pwd)"
echo "   Preset      : ${PRESET:-Custom}"
echo "   Description : ${DESCRIPTION:-<none>}"
echo "   Modules     : ${EXTRA_MODULES[*]}"
echo "   Next        : nix develop"
