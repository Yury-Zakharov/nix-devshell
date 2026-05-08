# nix-devshell

Reusable Nix devshell modules and templates.

**Goal**: Every development project gets a fully isolated, project-root-only environment.  
No global state, no `~/` paths, no implicit behaviour.  
Single declaration site for every module, overlay, preset, and tool.

## Create a new project

```bash
ndi                     # interactive (recommended)
ndi my-project
ndi --preset dotnet backend
ndi --dry-run --preset python-ai "AI workspace"
ndi --preset ai-dev --description "Agent swarm" swarm-agent
```

Or without the alias:

```bash
nix run github:Yury-Zakharov/nix-devshell#init
```

The CLI:
- Prompts for project directory + optional description
- Lets you choose a preset **or** Custom
- Shows module descriptions in the selector
- Always includes `base`
- Creates the project, initialises git, adds `.gitignore`
- Edits `flake.nix` with the exact modules (single declaration site)

**Shell alias** (add to your Home Manager config):

```nix
programs.zsh.initExtra = ''
  ndi() {
    nix run --refresh --no-eval-cache github:Yury-Zakharov/nix-devshell#init -- "$@"
  }
'';
```

## Available presets

- `minimal` – base only
- `dotnet` – dotnet + avalonia
- `python-ai` – python + opencode + claude
- `elm` – full Elm stack
- `ai-dev` – all AI tools
- `focus` – bmad-method + get-shit-done

## OpenCode Configuration (with free-first model rotation)

OpenCode is pre-configured with **7 generous free-tier providers** and automatic fallback:

- Free models are tried first (`local-qwen` → Gemini Flash → Groq → Cerebras → DeepSeek → Mistral → OpenRouter)
- Only after all free limits are exhausted does it ask for confirmation before using a paid model (`zai-glm`).

API keys are provided via `.envrc` (api keys never committed):

```bash
require_pass() {
  if ! pass "$1" >/dev/null 2>&1; then
    echo "Missing secret: $1"
    return 1
  fi
}

export_secret() {
  local path="$1"
  local var="$2"
  export "$var=$(pass "$path")"
}

require_pass user/llm/gemini/api-key
require_pass user/llm/groq/api-key
require_pass user/llm/cerebras/api-key
require_pass user/llm/deepseek/api-key
require_pass user/llm/mistral/api-key
require_pass user/llm/openrouter/api-key
require_pass user/llm/z-ai/api-key

export_secret user/llm/gemini/api-key GEMINI_API_KEY
export_secret user/llm/groq/api-key GROQ_API_KEY
export_secret user/llm/cerebras/api-key CEREBRAS_API_KEY
export_secret user/llm/deepseek/api-key DEEPSEEK_API_KEY
export_secret user/llm/mistral/api-key MISTRAL_API_KEY
export_secret user/llm/openrouter/api-key OPENROUTER_API_KEY
export_secret user/llm/z-ai/api-key ZAI_API_KEY
```

Role-based models are already set in `.opencode/opencode.jsonc`:
- `planModel` → Architect / planning
- `defaultModel` → Coder / implementation
- `fastModel` → Tester / reviewer

## Available modules (add only what you need)

- `base` – common XDG isolation + opencode + podman
- `dotnet` – .NET SDK + NuGet.Mcp.Server + RoslynMcp.Server
- `opencode` – full OpenCode with 7 free providers + fallback
- `opencode-skills` – declarative skills (Elm, .NET, etc.)
- `opencode-commands` – convenient aliases
- `elm` + `elm-opencode` – Elm toolchain + OpenCode support
- `gitnexus` + `gitnexus-mcp` – knowledge graph + MCP server
- `gsd`, `bmad-method` – autonomous agents

## Update an existing project

```bash
nix flake update devshell && direnv allow
```

## Add a new module / overlay / preset

See `modules/`, `overlays/`, and the `moduleDescriptions` + `presets` attrs in `flake.nix` — single declaration site.

---

**Made for multi-machine, zero-drift, fully isolated development.**

Everything lives inside the project root (`.opencode/`, `.gitnexus/`, `.nuget/`, `.cache/`, etc.).
