{ pkgs }:

{
  packages = [
    pkgs.opencode
  ];

  env = {
    # OpenCode respects these for full project isolation
    OPENCODE_CONFIG_DIR = "$PWD/.opencode";
    OPENCODE_CACHE_DIR  = "$PWD/.opencode/cache";
  };

  shellHook = ''
    mkdir -p "$OPENCODE_CONFIG_DIR"

    # Minimal declarative config — single source of truth per project
    if [ ! -f "$OPENCODE_CONFIG_DIR/opencode.jsonc" ]; then
      cat > "$OPENCODE_CONFIG_DIR/opencode.jsonc" << 'JSONC'
{
  // OpenCode configuration — fully declarative and project-local
  "models": {
    "local-qwen": {
      "provider": "openai-compatible",
      "baseUrl": "http://127.0.0.1:8080/v1",
      "model": "qwen3-30b-a3b-q5_k_m",
      "apiKey": "dummy"   // not used by llama.cpp but required by spec
    },
    "zai-glm": {
      "provider": "zai",
      "model": "glm-4-plus"   // replace with your exact GLM model name
      // API key will be injected via env or secrets
    }
    // Add more models here (single declaration site)
  },

  // Preferred model per task type (community favourite pattern)
  "defaultModel": "local-qwen",
  "planModel":    "local-qwen",
  "fastModel":    "local-qwen",

  // MCP servers (all run locally or via env vars)
  "mcp": {
    "gitnexus": {
      "type": "local",
      "command": ["gitnexus", "mcp"]
    },
    "context7": {
      "type": "remote",
      "url": "https://api.context7.com/mcp",
      "apiKey": "${CONTEXT7_API_KEY}"   // injected by you or secrets.nix
    }
    // deepwiki + other .NET-friendly MCPs added in Phase 2
  },

  // Skills & Commands will be auto-discovered from .opencode/skills/
  "skills": {
    "autoLoad": true
  }
}
JSONC
      echo "✅ Created minimal opencode.jsonc (project root)"
    fi

    echo "OpenCode ready — config: $OPENCODE_CONFIG_DIR/opencode.jsonc"
    echo "Run: opencode to start"
  '';
}
