final: prev:

{
  spec-kit = prev.python3Packages.buildPythonApplication {
    pname = "spec-kit";
    version = "1.2.3";

    src = prev.fetchFromGitHub {
      owner = "github";
      repo = "spec-kit";
      rev = "v1.2.3";
      sha256 = "005wzc2vyq7jbx352xcn387485iw84189xq0h2n14hci675q5k8d";
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
