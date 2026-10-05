final: prev:

{
  spec-kit = prev.python3Packages.buildPythonApplication {
    pname = "spec-kit";
    version = "1.1.0";

    src = prev.fetchFromGitHub {
      owner = "github";
      repo = "spec-kit";
      rev = "v1.1.0";
      sha256 = "1qz6y18m7z629cmv97nkshvigsi5q274xrxpzr46aqksx8rdvc9m";
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
