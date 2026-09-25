# Matt Pocock skills for project-local OpenCode.
#
# Source of truth: flake input `mattpocock-skills` (github:mattpocock/skills).
# This module does not own .opencode/skills/ — that directory stays shared
# discovery space. Owned files live in .opencode/matt-pocock-skills/.
# OpenCode finds them via symlinks that this hook manages explicitly.
#
# Does not touch: .specify/, spec-kit commands, oh-my-openagent.jsonc.
#
# Update (in nix-devshell):
#   nix flake update mattpocock-skills
#   git add flake.lock && git commit -m "chore: bump mattpocock/skills"
# Then in each project:
#   nix flake update devshell && direnv allow
#
# Categories included are declared below — single site, no implicit extras.

{ pkgs, src, rev ? "unknown" }:

let
  # Single declaration site for which upstream categories we take.
  # Matt's repo layout: skills/<category>/<name>/SKILL.md
  # OpenCode layout:    <name>/SKILL.md
  categories = [
    "engineering"
    "productivity"
  ];

  flattened = pkgs.runCommand "matt-pocock-skills-flat" {
    inherit src;
  } ''
    set -euo pipefail
    mkdir -p "$out"
    included=""

    ${pkgs.lib.concatMapStrings (cat: ''
      if [ -d "$src/skills/${cat}" ]; then
        for d in "$src/skills/${cat}"/*/; do
          [ -d "$d" ] || continue
          if [ ! -f "$d/SKILL.md" ]; then
            echo "skip (no SKILL.md): $d" >&2
            continue
          fi
          name=$(basename "$d")
          if [ -e "$out/$name" ]; then
            echo "error: duplicate skill name '$name' across categories" >&2
            exit 1
          fi
          cp -R "$d" "$out/$name"
          included="$included $name"
        done
      else
        echo "warning: upstream category missing: ${cat}" >&2
      fi
    '') categories}

    {
      echo "rev=${rev}"
      echo "src=''${src}"
      echo "categories=${pkgs.lib.concatStringsSep "," categories}"
      echo "skills:$included"
    } > "$out/.manifest"
    echo "${rev}" > "$out/.src-rev"
    echo "$included" | tr ' ' '\n' | sed '/^$/d' | sort > "$out/.managed-names"
  '';
in
{
  # No packages. Skills are files, not binaries.
  # No env. OPENCODE_CONFIG_DIR comes from the opencode module.

  shellHook = ''
    if [ -z "''${OPENCODE_CONFIG_DIR:-}" ]; then
      echo "matt-pocock-skills: OPENCODE_CONFIG_DIR unset — enable the opencode module first"
    else
      OWNED="$OPENCODE_CONFIG_DIR/matt-pocock-skills"
      SKILLS_DIR="$OPENCODE_CONFIG_DIR/skills"
      mkdir -p "$SKILLS_DIR"

      # Drop only the links we previously created, then replace the owned tree.
      if [ -f "$OWNED/.managed-names" ]; then
        while IFS= read -r name; do
          [ -n "$name" ] || continue
          link="$SKILLS_DIR/$name"
          if [ -L "$link" ]; then
            target=$(readlink "$link" || true)
            case "$target" in
              *matt-pocock-skills/"$name") rm -f "$link" ;;
            esac
          fi
        done < "$OWNED/.managed-names"
      fi

      rm -rf "$OWNED"
      mkdir -p "$OWNED"
      cp -R ${flattened}/. "$OWNED/"
      chmod -R u+w "$OWNED"

      collisions=""
      while IFS= read -r name; do
        [ -n "$name" ] || continue
        dest="$SKILLS_DIR/$name"
        if [ -e "$dest" ] && [ ! -L "$dest" ]; then
          collisions="$collisions $name"
          echo "matt-pocock-skills: skip '$name' — $dest already exists and is not our symlink"
          continue
        fi
        ln -sfn "../matt-pocock-skills/$name" "$dest"
      done < "$OWNED/.managed-names"

      if [ ! -f matt-pocock-skills-constitution-fragment.md ]; then
        cp ${./matt-pocock-skills/constitution-fragment.md} matt-pocock-skills-constitution-fragment.md
        chmod u+w matt-pocock-skills-constitution-fragment.md
        echo "matt-pocock-skills: wrote matt-pocock-skills-constitution-fragment.md (paste into constitution; not applied automatically)"
      fi

      echo "matt-pocock-skills: loaded into .opencode/matt-pocock-skills/ (symlinked for OpenCode discovery)"
      if [ -n "$collisions" ]; then
        echo "matt-pocock-skills: name collisions (left untouched):$collisions"
      fi
    fi
  '';
}
