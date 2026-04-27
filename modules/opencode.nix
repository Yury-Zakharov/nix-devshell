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
  "defaultModel": "local-qwen",
  "planModel":    "local-qwen",
  "fastModel":    "local-qwen",

  // Plugins
  "plugin": [
    "micode",
    "oh-my-opencode"
  ],

  // MCP servers
  "mcp": {
    "gitnexus": {
      "type": "local",
      "command": ["gitnexus", "mcp"],
      "enabled": true
    },
    "context7": {
      "type": "remote",
      "url": "https://api.context7.com/mcp",
      "apiKey": "${CONTEXT7_API_KEY}"
    }
    // .NET-friendly MCP examples (add when ready):
    // "nuget":   { "type": "local", "command": ["dotnet", "tool", "run", "NuGet.Mcp.Server"] },
    // "roslyn":  { "type": "local", "command": ["roslyn-mcp"] }
  },

  // Custom tools — gsd and bmad are now directly usable by OpenCode
  "tools": {
    "gsd": {
      "command": ["gsd"],
      "description": "GSD-2 autonomous coding agent"
    },
    "bmad": {
      "command": ["bmad-method"],
      "description": "BMAD-METHOD breakthrough development workflow"
    }
  },

  // Skills
  "skills": {
    "autoLoad": true
  }
}
JSONC
      echo "✅ Created full declarative opencode.jsonc with gsd + bmad integration"
    fi

    # Auto-install plugins
    opencode plugin install --yes 2>/dev/null || true

    echo "OpenCode ready"
    echo "Config:     $OPENCODE_CONFIG_DIR/opencode.jsonc"
    echo "Tools:      gsd and bmad-method are now available to OpenCode"
  '';
}
