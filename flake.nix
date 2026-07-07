{
  description = "Reusable Nix devshell modules and templates";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
    in
    {
      templates.default = {
        path = ./templates/default;
        description = "Standard devshell (base + optional modules)";
      };

      # Single declaration site for all available modules
      modules = {
        base         = import ./modules/base.nix;
        claude       = import ./modules/claude.nix;
        dotnet       = import ./modules/dotnet.nix;
        dotnet-8     = import ./modules/dotnet-8.nix;
        avalonia     = import ./modules/avalonia.nix;
        elm          = import ./modules/elm.nix;
        elm-land     = import ./modules/elm-land.nix;
        elm-spa      = import ./modules/elm-spa.nix;
        elm-opencode = import ./modules/elm-opencode.nix;
        gemini       = import ./modules/gemini.nix;
        get-shit-done = import ./modules/get-shit-done.nix;
        gsd          = import ./modules/gsd.nix;
        hugo         = import ./modules/hugo.nix;
        kilocode-cli = import ./modules/kilocode-cli.nix;
        opencode     = import ./modules/opencode.nix;
        opencode-skills = import ./modules/opencode-skills.nix;
        opencode-commands = import ./modules/opencode-commands.nix;
        python       = import ./modules/python.nix;
        qwen-code    = import ./modules/qwen-code.nix;
        rendercv     = import ./modules/rendercv.nix;
        spec-kit     = import ./modules/spec-kit.nix;
        swarmvault   = import ./modules/swarmvault.nix;
        bmad-method  = import ./modules/bmad-method.nix;
        gitnexus     = import ./modules/gitnexus.nix;
        gitnexus-mcp = import ./modules/gitnexus-mcp.nix;
        jq           = import ./modules/jq.nix;
        codegraph    = import ./modules/codegraph.nix;
        haskell      = import ./modules/haskell.nix;
        monomer      = import ./modules/monomer.nix;
        hsqml        = import ./modules/hsqml.nix;
        antigravity-cli = import ./modules/antigravity-cli.nix;
        typescript      = import ./modules/typescript.nix;
      };

      # Single declaration site for module metadata (used by #init CLI)
      moduleDescriptions = {
        base          = "Base development environment with common tools, XDG dirs, podman socket";
        claude        = "Claude AI integration (opencode + claude tools)";
        dotnet        = ".NET LTS SDK, dotnet CLI tools, C# language server";
        dotnet-8      = ".NET 8 SDK, dotnet CLI tools, C# language server";
        avalonia      = "Avalonia UI framework for cross-platform .NET desktop apps";
        elm           = "Elm language, compiler, and dev tools";
        elm-land      = "Elm Land framework for full-stack Elm apps";
        elm-spa       = "Elm SPA framework and tools";
        elm-opencode  = "Elm + Opencode AI integration";
        gemini        = "Gemini AI integration (opencode + gemini tools)";
        get-shit-done = "get-shit-done: SDD tool";
        gsd           = "get-shit-done v2";
        hugo          = "Hugo static site generator";
        kilocode-cli  = "Kilocode CLI (AI coding assistant)";
        opencode      = "Opencode AI coding assistant";
        opencode-skills = "Opencode skills / custom prompts";
        opencode-commands = "Opencode custom commands";
        python        = "Python 3 + common tools, uv, ruff, mypy";
        qwen-code     = "Qwen AI coding integration";
        rendercv      = "RenderCV: Yaml -> PDF CV generator";
        spec-kit      = "Spec Kit: SDD tools";
        swarmvault    = "SwarmVault: Agent wiki";
        bmad-method   = "BMAD method (focus / productivity tools)";
        gitnexus      = "GitNexus: knowledge base";
        gitnexus-mcp  = "GitNexus MCP server";
        jq            = "jq + jq tools for JSON processing";
        codegraph     = "CodeGraph: local code knowledge graph + MCP for opencode (perfect with dotnet)";
        haskell       = "Haskell + Stack";
        monomer       = "Haskell GUI, use it with haskell module";
        hsqml         = "Another Haskell GUI, qt way";
        antigravity-cli = "Google Antigravity CLI (agy) — best-effort isolation only";
        typescript      = "TypeScript compiler (tsc) + Node.js runtime";
      };

      # Single declaration site for presets (used by #init CLI)
      presets = {
        minimal   = [ ];
        dotnet-ai = [ "dotnet" "spec-kit" "opencode" "codegraph"];
        dotnet-ui = [ "dotnet" "avalonia" ];
        python-ai = [ "python" "opencode" ];
        elm       = [ "elm" "elm-land" "elm-spa" "elm-opencode" ];
        ai-dev    = [ "opencode" "claude" "gemini" "kilocode-cli" ];
        heavy-sdd = [ "bmad-method" "dotnet" "opencode" ];
        haskel-ai = [ "opencode" "haskell" ];
        haskel-ui = [ "monomer" "haskell" ];
      };

      overlays = import ./overlays.nix;

      lib = {
        # Evaluate each module function with pkgs before passing to default.nix
        mkDevShell = { pkgs, extraModules ? [] }:
          let
            evaluatedModules = map (m: m { inherit pkgs; }) extraModules;
          in
          import ./default.nix {
            inherit pkgs;
            extraModules = evaluatedModules;
          };
      };

      # init CLI
      packages.${system}.init = let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in pkgs.writeShellApplication {
        name = "devshell-init";
        runtimeInputs = [ pkgs.gum pkgs.jq pkgs.git ];
        text = builtins.readFile ./scripts/init.sh;
      };

      apps.${system}.init = {
        type = "app";
        program = "${self.packages.${system}.init}/bin/devshell-init";
      };
    };
}
