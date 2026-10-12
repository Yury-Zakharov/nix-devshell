final: prev:

{
  spec-kit = prev.python3Packages.buildPythonApplication {
    pname = "spec-kit";
    version = "1.1.3";

    src = prev.fetchFromGitHub {
      owner = "github";
      repo = "spec-kit";
      rev = "v1.1.3";
      sha256 = "0b9w76rm2m711pxr717mhx1x70qy19fbavk1wkyg8r8wr00l75rc";
    };

    pyproject = true;

    nativeBuildInputs = with prev.python3Packages; [
      hatchling
    ];

    propagatedBuildInputs = with prev.python3Packages; [
    click
    json5
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
