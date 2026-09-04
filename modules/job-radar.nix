{ pkgs }:

{
  packages = [
    pkgs.job-radar
    pkgs.git
  ];

  env = {
    JOB_RADAR_HOME   = "$PWD/.job-radar";
    JOB_RADAR_CONFIG = "$PWD/.job-radar/config.yaml";
    JOB_RADAR_DOCS   = "$PWD/.job-radar/docs";
  };

  shellHook = ''
    mkdir -p "$PWD/.job-radar"/{data,out,state,docs,seed,.seed-cache,.backups}

    if [ -f "$PWD/.gitignore" ] && ! grep -qxF '.job-radar/' "$PWD/.gitignore"; then
      printf '\n# job-radar isolated state (config, sqlite, seed, drafts)\n.job-radar/\n' >> "$PWD/.gitignore"
      echo "✓ .job-radar/ added to .gitignore"
    fi

    if [ ! -f "$PWD/.job-radar/config.example.yaml" ]; then
      cp ${pkgs.job-radar.exampleConfig} "$PWD/.job-radar/config.example.yaml"
      chmod u+w "$PWD/.job-radar/config.example.yaml"
    fi

    # Claude Code user-skills dir is CLAUDE_CONFIG_DIR (claude.nix),
    # which is $XDG_CONFIG_HOME/claude → $PWD/.config/claude
    # under base.nix. Never ~/.claude and never a folder named .claude
    # (Claude Code would treat that as project-scope settings).
    _jr_claude_root="''${CLAUDE_CONFIG_DIR:-$XDG_CONFIG_HOME/claude}"
    _jr_skills="$_jr_claude_root/skills"
    mkdir -p "$_jr_skills"

    _jr_copy_skill() {
      local name="$1"
      local src="${pkgs.job-radar.skills}/$name"
      if [ ! -d "$src" ]; then
        return 0
      fi
      if [ -e "$_jr_skills/$name" ]; then
        return 0
      fi
      cp -a "$src" "$_jr_skills/$name"
      chmod -R u+w "$_jr_skills/$name"
      # Skills ship with ~/... paths. Rewrite to this project's isolated dirs.
      if [ -f "$_jr_skills/$name/SKILL.md" ]; then
        sed -i \
          -e "s|~/.claude/skills|$_jr_skills|g" \
          -e "s|~/job-radar/config.local.yaml|$PWD/.job-radar/config.local.yaml|g" \
          -e "s|~/job-radar/config.yaml|$PWD/.job-radar/config.yaml|g" \
          -e "s|~/job-radar/config.example.yaml|$PWD/.job-radar/config.example.yaml|g" \
          -e "s|~/job-radar|$PWD/.job-radar|g" \
          "$_jr_skills/$name/SKILL.md"
      fi
      echo "✓ Claude skill $name → $_jr_skills/$name"
    }

    _jr_copy_skill rate-cv
    _jr_copy_skill screen-role
    _jr_copy_skill job-radar-setup

    # natural-writing is a separate repo and is required by generate + rate-cv.
    # Latest clone, first run only. Delete the dir to refresh.
    if [ ! -e "$_jr_skills/natural-writing" ]; then
      echo "→ cloning maccydee/natural-writing into $_jr_skills/natural-writing"
      git clone --depth 1 https://github.com/maccydee/natural-writing.git \
        "$_jr_skills/natural-writing"
      chmod -R u+w "$_jr_skills/natural-writing"
      if [ -f "$_jr_skills/natural-writing/SKILL.md" ]; then
        sed -i -e "s|~/.claude/skills|$_jr_skills|g" \
          "$_jr_skills/natural-writing/SKILL.md"
      fi
      echo "✓ Claude skill natural-writing → $_jr_skills/natural-writing"
    fi

    echo "job-radar: $(job-radar --help >/dev/null 2>&1 && echo ready || echo wrapper-on-PATH)"
    echo "job-radar state:  $PWD/.job-radar/"
    echo "Claude skills:    $_jr_skills"
    echo "  rate-cv / screen-role / job-radar-setup / natural-writing"
    echo ""
    echo "First run (CV path is expanded in this shell, before the wrapper cds):"
    echo "  job-radar setup --cv \"\$PWD/cv.yaml\" --titles \"backend engineer, senior software engineer\" --countries UK"
    echo ""
    echo "Daily:"
    echo "  job-radar scan"
    echo "  job-radar list --new"
    echo "  job-radar serve               # 127.0.0.1:8765"
    echo ""
    echo "rank / generate / dashboard drafts: claude module + signed-in claude CLI."
  '';
}
