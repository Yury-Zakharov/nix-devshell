{ pkgs }:

let
  opencodeConfig = pkgs.writeTextFile {
    name = "opencode.jsonc";
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";

      # Default model for normal use
      model = "local-qwen";

      # Full definition of all models
      models = {
        local-qwen = {
          provider = "openai-compatible";
          baseUrl = "http://127.0.0.1:8080/v1";
          model = "qwen3-30b-a3b-q5_k_m";
          apiKey = "dummy";
        };
      };

      provider = {
        google    = { apiKey = "{env:GEMINI_API_KEY}"; };
        groq      = { baseUrl = "https://api.groq.com/openai/v1"; apiKey = "{env:GROQ_API_KEY}"; };
        cerebras  = { baseUrl = "https://api.cerebras.ai/v1"; apiKey = "{env:CEREBRAS_API_KEY}"; };
        deepseek  = { baseUrl = "https://api.deepseek.com"; apiKey = "{env:DEEPSEEK_API_KEY}"; };
        mistral   = { apiKey = "{env:MISTRAL_API_KEY}"; };
        openrouter = { baseUrl = "https://openrouter.ai/api/v1"; apiKey = "{env:OPENROUTER_API_KEY}"; };
        zai       = { apiKey = "{env:ZAI_API_KEY}"; };
      };

      plugin = [ "micode" "oh-my-openagent" ];

      mcp = {
        context7 = { type = "remote"; url = "https://api.context7.com/mcp"; apiKey = "{env:CONTEXT7_API_KEY}"; };
        gitnexus = { type = "local"; command = ["gitnexus" "mcp"]; enabled = false; };
        nuget    = { type = "local"; command = ["dotnet" "tool" "run" "NuGet.Mcp.Server"]; enabled = false; };
        roslyn   = { type = "local"; command = ["dotnet" "tool" "run" "RoslynMcp.Server"]; enabled = false; };
      };

      skills = { autoLoad = true; };
    };
  };
in

{
  packages = [
    pkgs.opencode
    pkgs.nodejs
  ];

  env = {
    OPENCODE_CONFIG_DIR = "$PWD/.opencode";
    OPENCODE_CACHE_DIR  = "$PWD/.opencode/cache";
  };

  shellHook = ''
    mkdir -p "$OPENCODE_CONFIG_DIR" "$OPENCODE_CONFIG_DIR/skills"

    if [ ! -f "$OPENCODE_CONFIG_DIR/opencode.jsonc" ]; then
      cp ${opencodeConfig} "$OPENCODE_CONFIG_DIR/opencode.jsonc"
      echo "✅ Created clean opencode.jsonc with proper local-qwen definition"
    fi

    opencode plugin install --yes 2>/dev/null || true
    echo "OpenCode ready"
  '';
}
