{ pkgs }:

{
  packages = [
    pkgs.job-radar
  ];

  env = {
    # Wrapper also defaults these. Declaring them here makes the
    # contract visible in `env` and matches how claude / qwen-code
    # modules pin their dirs.
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

    echo "job-radar: $(job-radar --help >/dev/null 2>&1 && echo ready || echo wrapper-on-PATH)"
    echo "job-radar state: fully isolated in $PWD/.job-radar/"
    echo "  config  $PWD/.job-radar/config.yaml"
    echo "  db      $PWD/.job-radar/data/job-radar.db"
    echo "  docs    $PWD/.job-radar/docs"
    echo ""
    echo "First run (CV path is expanded in this shell, before the wrapper cds):"
    echo "  job-radar setup --cv \"\$PWD/cv.yaml\" --titles \"backend engineer, senior software engineer\" --countries UK"
    echo "  job-radar setup --defaults --no-seed --cv \"\$PWD/cv.yaml\" --titles \"backend engineer\""
    echo ""
    echo "Daily:"
    echo "  job-radar seed load https://github.com/maccydee/job-radar/releases/download/seed-latest"
    echo "  job-radar scan --limit 200    # smoke; full scan is ~1h (Workable pace)"
    echo "  job-radar scan"
    echo "  job-radar list --new"
    echo "  job-radar serve               # 127.0.0.1:8765"
    echo ""
    echo "rank / generate / dashboard draft buttons need the claude module"
    echo "and a signed-in claude CLI (tokens billed per call)."
  '';
}
