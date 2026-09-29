final: prev:

{
  spec-kit = prev.python3Packages.buildPythonApplication {
    pname = "spec-kit";
    version = "1.0.12";

    src = prev.fetchFromGitHub {
      owner = "github";
      repo = "spec-kit";
      rev = "v1.0.12";
      sha256 = "12c2aisklc3s40b3glbjmidz46r6ylfmkj8ryrgng5x2x32jg9yb";
    };

    pyproject = true;

    nativeBuildInputs = with prev.python3Packages; [
      hatchling
    ];

    propagatedBuildInputs = with prev.python3Packages; [
    click
    json5
    packaging
    pathspec
    pyyaml
    readchar
    rich
    typer
    ];

    pythonImportsCheck = [ "specify_cli" ];
  };
}
