{ pkgs }:

{
  packages = [
    pkgs.opencode
  ];

  env = {
    OPENCODE_CONFIG_DIR = "$PWD/.opencode";
    OPENCODE_CACHE_DIR  = "$PWD/.opencode/cache";
  };

  shellHook = ''
    mkdir -p "$OPENCODE_CONFIG_DIR" "$OPENCODE_CONFIG_DIR/skills"

    if [ ! -f "$OPENCODE_CONFIG_DIR/opencode.jsonc" ]; then
      cat > "$OPENCODE_CONFIG_DIR/opencode.jsonc" << 'JSONC'
{
  "$schema": "https://opencode.ai/config.json",

  // Default model for normal coding tasks
  "model": "local-qwen",

  // Provider configurations (using env vars)
  "provider": {
    "google": {
      "apiKey": "{env:GEMINI_API_KEY}"
    },
    "groq": {
      "baseUrl": "https://api.groq.com/openai/v1",
      "apiKey": "{env:GROQ_API_KEY}"
    },
    "cerebras": {
      "baseUrl": "https://api.cerebras.ai/v1",
      "apiKey": "{env:CEREBRAS_API_KEY}"
    },
    "deepseek": {
      "baseUrl": "https://api.deepseek.com",
      "apiKey": "{env:DEEPSEEK_API_KEY}"
    },
    "mistral": {
      "apiKey": "{env:MISTRAL_API_KEY}"
    },
    "openrouter": {
      "baseUrl": "https://openrouter.ai/api/v1",
      "apiKey": "{env:OPENROUTER_API_KEY}"
    },
    "zai": {
      "apiKey": "{env:ZAI_API_KEY}"
    }
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

  "tools": {
    "gsd":  { "command": ["gsd"],   "description": "GSD-2 autonomous coding agent" },
    "bmad": { "command": ["bmad-method"], "description": "BMAD-METHOD breakthrough workflow" }
  },

  "skills": { "autoLoad": true }
}
JSONC
      echo "✅ Created valid minimal opencode.jsonc (compatible with current OpenCode)"
    fi

    opencode plugin install --yes 2>/dev/null || true
    echo "OpenCode ready"
  '';
}
