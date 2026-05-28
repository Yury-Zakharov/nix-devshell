{ pkgs }:

{
  packages = [ pkgs.spec-kit ];

  shellHook = ''
    export SPEC_KIT_HOME="$XDG_CACHE_HOME/spec-kit"
    mkdir -p "$SPEC_KIT_HOME"

    echo "Spec-kit: $(specify version 2>/dev/null || echo "not found")"

    # Copy best-practices document (always available in project root)
    if [ ! -f "./best-practices.md" ]; then
      mkdir -p .github
      cp ${./spec-kit/best-practices.md} ./best-practices.md
      chmod u+w ./best-practices.md
      echo "✓ best-practices.md copied to project root"
    fi

    # Copy our custom constitution as example (user will apply it manually via /speckit.constitution)
    if [ ! -f "./constitution-example.md" ]; then
      cp ${./spec-kit/defaults/constitution.md} ./constitution-example.md
      chmod u+w ./constitution-example.md
      echo "✓ constitution-example.md copied to project root"
      echo "   → Run '/speckit.constitution' manually when ready to apply it"
    fi

    # Pre-configure GitHub workflow files (copied only on first run)
    if [ ! -d ".github/workflows" ]; then
      mkdir -p .github/workflows
      cp ${./spec-kit/defaults/.github/workflows/ci.yml} .github/workflows/ci.yml
      chmod u+w .github/workflows/ci.yml
      echo "✓ GitHub CI workflow copied"
    fi

    if [ ! -f ".github/pull_request_template.md" ]; then
      mkdir -p .github
      cp ${./spec-kit/defaults/.github/pull_request_template.md} .github/pull_request_template.md
      chmod u+w .github/pull_request_template.md
      echo "✓ GitHub PR template copied"
    fi
  '';
}
