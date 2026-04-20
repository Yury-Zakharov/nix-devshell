final: prev:

{
  spec-kit = prev.python3Packages.buildPythonApplication {
    pname = "spec-kit";
    version = "0.5.0";

    src = prev.fetchFromGitHub {
      owner = "github";
      repo = "spec-kit";
      rev = "v0.5.0";
      sha256 = "0gyayxk77f2qrgg33hi1rrl9443gfq3qx8nj78ahhd1k8aj16m8y";
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
