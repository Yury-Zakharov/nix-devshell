final: prev:

{
  spec-kit = prev.python3Packages.buildPythonApplication {
    pname = "spec-kit";
    version = "1.3.3";

    src = prev.fetchFromGitHub {
      owner = "github";
      repo = "spec-kit";
      rev = "v1.3.3";
      sha256 = "0mpa4x1gb3kv1wrscfwjmqjw24ba0rxqpk8rd7m7qmlfjf4qamxr";
    };

    pyproject = true;

    nativeBuildInputs = with prev.python3Packages; [
      hatchling
    ];

    propagatedBuildInputs = with prev.python3Packages; [
    click
    json5
    lark
    mcp
    packaging
    pathspec
    pydantic
    pyyaml
    readchar
    rich
    typer
    ];

    pythonImportsCheck = [ "specify_cli" ];
  };
}
