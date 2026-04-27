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

  // Models — generous free tier, modern, no deposit required
  "models": {
    "local-qwen": {
      "provider": "openai-compatible",
      "baseUrl": "http://127.0.0.1:8080/v1",
      "model": "qwen3-30b-a3b-q5_k_m",
      "apiKey": "dummy"
    },

    "gemini-flash": {
      "provider": "google",
      "model": "gemini-2.5-flash",
      "apiKey": "{env:GEMINI_API_KEY}"
    },
    "gemini-pro": {
      "provider": "google",
      "model": "gemini-2.5-pro",
      "apiKey": "{env:GEMINI_API_KEY}"
    },

    "groq-llama": {
      "provider": "openai-compatible",
      "baseUrl": "https://api.groq.com/openai/v1",
      "model": "llama-4-scout-17b",
      "apiKey": "{env:GROQ_API_KEY}"
    },

    "cerebras-llama": {
      "provider": "openai-compatible",
      "baseUrl": "https://api.cerebras.ai/v1",
      "model": "llama-3.3-70b",
      "apiKey": "{env:CEREBRAS_API_KEY}"
    },

    "deepseek-r1": {
      "provider": "openai-compatible",
      "baseUrl": "https://api.deepseek.com",
      "model": "deepseek-reasoner",
      "apiKey": "{env:DEEPSEEK_API_KEY}"
    },

    "mistral-large": {
      "provider": "mistral",
      "model": "mistral-large-3",
      "apiKey": "{env:MISTRAL_API_KEY}"
    },

    "openrouter-free": {
      "provider": "openai-compatible",
      "baseUrl": "https://openrouter.ai/api/v1",
      "model": "meta-llama/llama-4-scout-17b",
      "apiKey": "{env:OPENROUTER_API_KEY}"
    },

    "zai-glm": {
      "provider": "zai",
      "model": "glm-4-plus",
      "apiKey": "{env:ZAI_API_KEY}"
    }
  },

  // Role-based model assignment
  "defaultModel": "local-qwen",   // Coder role — implementation
  "planModel":    "local-qwen",   // Architect role — planning & design
  "fastModel":    "local-qwen",   // Tester / Reviewer role — quick validation

  // Fallback plugin — free-first rotation
  "plugin": [
    "micode",
    "oh-my-opencode",
    "opencode-rate-limit-fallback"
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

  "skills": { "autoLoad": true },

  // Free-first fallback chain (paid only as last resort)
  "fallback": {
    "enabled": true,
    "chain": [
      "local-qwen",
      "gemini-flash",
      "groq-llama",
      "cerebras-llama",
      "deepseek-r1",
      "mistral-large",
      "openrouter-free",
      "zai-glm"
    ],
    "askBeforePaid": true
  }
}
JSONC
      echo "✅ Created opencode.jsonc with correct {env:VAR} syntax"
    fi

    opencode plugin install --yes 2>/dev/null || true
    echo "OpenCode ready with free-first model rotation"
  '';
}
