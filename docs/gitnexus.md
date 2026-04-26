# Working with GitNexus


[GitNexus](https://github.com/abhigyanpatwari/GitNexus) is an open-source, MCP-native knowledge graph engine that gives AI coding agents (Claude Code, Cursor, etc.) full structural awareness of your codebase.  
It builds a local graph of functions, imports, call chains, clusters, and execution flows, stored entirely inside your project.

**Huge thanks** to Abhigyan Patwari for creating this excellent tool and making it freely available.

All data lives in `./.gitnexus/` (project root). Nothing is stored outside your project.

## Two typical scenarios

### 1. New project
1. Add the module in your project’s `flake.nix`:
   ```nix
   extraModules = [
     devshell.modules.base
     devshell.modules.gitnexus
     # devshell.modules.gitnexus-mcp   # optional: auto-start MCP server
   ];
   ```
2. Run:
   ```bash
   nix flake update devshell && direnv allow
   ```
3. Index the codebase:
   ```bash
   gitnexus analyze          # builds the knowledge graph (first run takes longer)
   ```
4. (Optional) Generate agent skills:
   ```bash
   gitnexus analyze --skills
   ```
5. Start using the MCP server (either manually with `gitnexus mcp` or via the `gitnexus-mcp` module).

### 2. Existing project
1. Enter the project directory and run:
   ```bash
   nix flake update devshell && direnv allow
   ```
2. Check index status:
   ```bash
   gitnexus status
   ```
3. Re-index if needed (see below) and continue working.

## Re-indexing

- **When**: After any commit that changes code structure, imports, function signatures, or entry points.  
  The index becomes “stale” when the graph no longer matches the current code.
- **Who runs it**: You (the developer) run the command. Agents can *suggest* re-indexing via PostToolUse hooks, but they cannot execute it themselves.
- **Frequency**:
  - Daily or after every major PR merge is usually enough.
  - For active development: run once per session or after significant refactors.
- **Commands**:
   ```bash
   gitnexus analyze              # incremental (fast, recommended)
   gitnexus analyze --force      # full re-index (when incremental fails)
   gitnexus analyze --skip-embeddings  # faster, without vector search
   gitnexus analyze --skills     # also regenerate agent skill files
   ```

For full details see the official documentation:  
https://github.com/abhigyanpatwari/GitNexus

## Common commands

- `gitnexus analyze` → build or update the knowledge graph  
- `gitnexus mcp` → start the MCP server (for Claude Code / Cursor)  
- `gitnexus serve` → start HTTP server + web UI bridge (port 4747)  
- `gitnexus status` → show index health  
- `gitnexus list` → list all indexed repositories  
- `gitnexus clean` → delete index for current repo (rarely needed)

## MCP Integration (Claude Code / Cursor)

Once the MCP server is running (`gitnexus mcp` or via `gitnexus-mcp` module), your AI agents automatically gain:
- `impact` – blast radius of a change
- `context` – full symbol relationships
- `detect_changes` – git-diff risk analysis
- `rename` – safe multi-file symbol renames

No extra configuration is required in most cases — the devshell module already exposes the server correctly.

## Quick reference

- Everything stays inside `./.gitnexus/`
- Indexes are portable and git-ignored by default
- Re-indexing is explicit and idempotent

For advanced features (groups, wiki generation, Cypher queries, etc.) refer to the official README:  
https://github.com/abhigyanpatwari/GitNexus
