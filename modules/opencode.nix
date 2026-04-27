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

  // Models
  "models": {
    "local-qwen": {
      "provider": "openai-compatible",
      "baseUrl": "http://127.0.0.1:8080/v1",
      "model": "qwen3-30b-a3b-q5_k_m",
      "apiKey": "dummy"
    },
    "zai-glm": {
      "provider": "zai",
      "model": "glm-4-plus"
    }
  },

  // Role-based models (free-first)
  "defaultModel": "local-qwen",   // Coder / main work
  "planModel":    "local-qwen",   // Architect / planning
  "fastModel":    "local-qwen",   // Tester / quick tasks

  // Fallback plugin — free-first rotation + eventual paid fallback
  "plugin": [
    "micode",
    "oh-my-opencode",
    "opencode-rate-limit-fallback"   // ← enables automatic model rotation on rate limits
  ],

  "mcp": {
    "gitnexus": { "type": "local", "command": ["gitnexus", "mcp"], "enabled": true },
    "context7": { "type": "remote", "url": "https://api.context7.com/mcp", "apiKey": "${CONTEXT7_API_KEY}" },
    "nuget":    { "type": "local", "command": ["dotnet", "tool", "run", "NuGet.Mcp.Server"], "enabled": true },
    "roslyn":   { "type": "local", "command": ["roslyn-mcp"], "enabled": true }
  },

  "tools": {
    "gsd":  { "command": ["gsd"],   "description": "GSD-2 autonomous coding agent" },
    "bmad": { "command": ["bmad-method"], "description": "BMAD-METHOD breakthrough workflow" }
  },

  "skills": { "autoLoad": true },

  // Fallback configuration (free → paid)
  "fallback": {
    "enabled": true,
    "chain": ["local-qwen", "zai-glm"],
    "askBeforePaid": true
  }
}
JSONC
      echo "✅ Created opencode.jsonc with free-first fallback (local-qwen → zai-glm)"
    fi

    opencode plugin install --yes 2>/dev/null || true
    echo "OpenCode ready with free-first model rotation"
  '';
}
