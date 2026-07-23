final: prev:

{
  spec-kit = prev.python3Packages.buildPythonApplication {
    pname = "spec-kit";
    version = "0.13.4";

    src = prev.fetchFromGitHub {
      owner = "github";
      repo = "spec-kit";
      rev = "v0.13.4";
      sha256 = "1aiz5cffyf0miniwhqh61ivfjzc257x6mfi2qhxk294ar52iqxp4";
    };

    pyproject = true;

    nativeBuildInputs = with prev.python3Packages; [
      hatchling
    ];

    propagatedBuildInputs = with prev.python3Packages; [
      click
      pyyaml
      httpx
      platformdirs
      readchar
      rich
      truststore
      typer
      json5                  # ← added: required runtime dep from pyproject.toml
    ];

    pythonImportsCheck = [ "specify_cli" ];
  };
}
