{ pkgs }:

{
  packages = [
    pkgs.opencode
    pkgs.nodejs          # for npx (context7)
  ];

  env = {
    OPENCODE_CONFIG_DIR = "$PWD/.opencode";
    OPENCODE_CACHE_DIR  = "$PWD/.opencode/cache";
  };

  shellHook = ''
    mkdir -p "$OPENCODE_CONFIG_DIR" "$OPENCODE_CONFIG_DIR/skills"

    # Export full PATH so OpenCode can find MCP binaries (gitnexus, roslyn-mcp, etc.)
    export PATH="${pkgs.lib.makeBinPath [
      pkgs.opencode
      pkgs.nodejs
      pkgs.git               # just in case
    ]}:$PATH"

    if [ ! -f "$OPENCODE_CONFIG_DIR/opencode.jsonc" ]; then
      cat > "$OPENCODE_CONFIG_DIR/opencode.jsonc" << 'JSONC'
{
  "$schema": "https://opencode.ai/config.json",

  "model": "local-qwen",

  "provider": {
    "google":    { "apiKey": "{env:GEMINI_API_KEY}" },
    "groq":      { "baseUrl": "https://api.groq.com/openai/v1",      "apiKey": "{env:GROQ_API_KEY}" },
    "cerebras":  { "baseUrl": "https://api.cerebras.ai/v1",         "apiKey": "{env:CEREBRAS_API_KEY}" },
    "deepseek":  { "baseUrl": "https://api.deepseek.com",           "apiKey": "{env:DEEPSEEK_API_KEY}" },
    "mistral":   { "apiKey": "{env:MISTRAL_API_KEY}" },
    "openrouter": { "baseUrl": "https://openrouter.ai/api/v1",      "apiKey": "{env:OPENROUTER_API_KEY}" },
    "zai":       { "apiKey": "{env:ZAI_API_KEY}" }
  },

  "plugin": [
    "micode",
    "oh-my-opencode"
  ],

  "mcp": {
    "gitnexus": { "type": "local", "command": ["gitnexus", "mcp"], "enabled": true },
    "context7": { "type": "remote", "url": "https://api.context7.com/mcp", "apiKey": "{env:CONTEXT7_API_KEY}" },
    "nuget":    { "type": "local", "command": ["dotnet", "tool", "run", "NuGet.Mcp.Server"], "enabled": true },
    "roslyn":   { "type": "local", "command": ["roslyn-mcp"], "enabled": true }
  },

  "skills": { "autoLoad": true }
}
JSONC
      echo "✅ Created minimal valid opencode.jsonc"
    fi

    opencode plugin install --yes 2>/dev/null || true
    echo "OpenCode ready (PATH exported for MCP servers)"
  '';
}
