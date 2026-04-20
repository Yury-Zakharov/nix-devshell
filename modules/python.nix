{ pkgs }:

{
  packages = [
    # Full Python with pip included (not just the interpreter)
    (pkgs.python312.withPackages (ps: with ps; [
      pip
      setuptools
      wheel
      virtualenv   # if you want venv management
    ]))
  ];

  env = {
    # Project-local virtual environment (explicit, no global pollution)
    VIRTUAL_ENV = "$PWD/.venv";
    PYTHONPATH = "";   # reset to avoid nix store leakage
  };

  shellHook = ''
    # Explicit directory setup — zero implicit state
    mkdir -p "$VIRTUAL_ENV"

    # Create .venv if it doesn't exist
    if [ ! -f "$VIRTUAL_ENV/bin/activate" ]; then
      echo "Creating project-local Python virtual environment in .venv..."
      python -m venv "$VIRTUAL_ENV" --prompt "$(basename $PWD)"
    fi

    # Activate the venv (this is safe and explicit)
    source "$VIRTUAL_ENV/bin/activate"

    # Prevent venv from overwriting .gitignore every time
    if [ ! -f "$PWD/.gitignore" ]; then
      cat > "$PWD/.gitignore" << 'EOF'
# Nix + direnv
.direnv/
.envrc.cache*

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual Environment
.venv/
EOF
      echo "✅ Created clean .gitignore (no automatic venv overwrite)"
    fi

    echo "✅ Python environment ready"
    echo "   Python: $(python --version)"
    echo "   pip:    $(pip --version)"
    echo "   venv:   $VIRTUAL_ENV"
  '';
}
