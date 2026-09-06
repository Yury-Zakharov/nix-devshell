final: prev:

{
  job-radar = let
    python = prev.python312;
    py = python.pkgs;

    # Unwrapped install lives in the Nix store. The public `job-radar`
    # binary is the wrapper below — it is the single owner of workdir
    # and of every relative default the upstream CLI uses (config.yaml,
    # data/job-radar.db, out/, state/, seed/).
    job-radar-unwrapped = py.buildPythonApplication rec {
      pname = "job-radar";
      version = "0.1.0-unstable-2026-09-06";

      src = prev.fetchFromGitHub {
        owner = "maccydee";
        repo = "job-radar";
        rev = "3db49833bad20f5a1dbef4d3d18d4c1713181cac";
        # Unpacked-tree hash. Refresh with scripts/update-job-radar.sh
        sha256 = "0f9pwapjdfxc45yrscxvhqynq1ridapdic3aayfcry6rpk15084j";
      };

      pyproject = true;

      nativeBuildInputs = [
        py.setuptools
        py.wheel
      ];

      propagatedBuildInputs = [
        py.requests
        py.pyyaml
        py.pypdf
      ];

      pythonImportsCheck = [ "jobradar" ];

      # Upstream suite talks to live ATS hosts and is not a package check.
      doCheck = false;

      # BUNDLED sources and bundled skills are resolved as
      #   Path(__file__).parent.parent / "sources|skills"
      # which is site-packages/ after install, not the repo root.
      postInstall = ''
        site="$out/${python.sitePackages}"
        mkdir -p "$site/sources" "$site/skills" "$out/share/job-radar"
        cp -r sources/. "$site/sources/"
        cp -r skills/.  "$site/skills/"
        # Same tree, stable path for the module to copy into CLAUDE_CONFIG_DIR.
        cp -r skills "$out/share/job-radar/skills"
        cp config.example.yaml "$out/share/job-radar/config.example.yaml"
      '';

      # Rank / generate look in ~/.claude/skills. Redirect that lookup
      # to CLAUDE_CONFIG_DIR when the claude module is also loaded
      # (that module sets CLAUDE_CONFIG_DIR=$XDG_CONFIG_HOME/claude,
      # and base.nix pins XDG_* to the project root).
      postPatch = ''
        substituteInPlace jobradar/runner.py \
          --replace-fail 'Path.home() / ".claude" / "skills"' \
                         'Path(os.environ.get("CLAUDE_CONFIG_DIR") or str(Path.home() / ".claude")) / "skills"'
      '';

      meta = with prev.lib; {
        description = "Watch employer ATS boards directly and keep only roles that pass your filters";
        homepage = "https://github.com/maccydee/job-radar";
        license = licenses.mit;
        mainProgram = "job-radar";
        platforms = platforms.unix;
      };
    };
  in
  (prev.writeShellApplication {
    name = "job-radar";
    runtimeInputs = [
      job-radar-unwrapped
      prev.coreutils
    ];
    text = ''
      # Single owner: overlays/job-radar.nix
      # Every relative path the CLI uses (config.yaml, data/, out/,
      # state/, seed/, docs/) is forced under $PWD/.job-radar/.
      # Override with JOB_RADAR_HOME if a project needs a different root.

      JOB_RADAR_PROJECT_ROOT="''${JOB_RADAR_PROJECT_ROOT:-$PWD}"
      export JOB_RADAR_PROJECT_ROOT

      JOB_RADAR_HOME="''${JOB_RADAR_HOME:-$JOB_RADAR_PROJECT_ROOT/.job-radar}"
      mkdir -p "$JOB_RADAR_HOME"/{data,out,state,docs,seed,.seed-cache,.backups}
      export JOB_RADAR_HOME

      export JOB_RADAR_CONFIG="''${JOB_RADAR_CONFIG:-$JOB_RADAR_HOME/config.yaml}"
      export JOB_RADAR_DOCS="''${JOB_RADAR_DOCS:-$JOB_RADAR_HOME/docs}"

      cd "$JOB_RADAR_HOME"
      exec ${job-radar-unwrapped}/bin/job-radar "$@"
    '';
  }).overrideAttrs (old: {
    passthru = (old.passthru or {}) // {
      unwrapped = job-radar-unwrapped;
      skills = "${job-radar-unwrapped}/share/job-radar/skills";
      exampleConfig = "${job-radar-unwrapped}/share/job-radar/config.example.yaml";
    };
  });
}
