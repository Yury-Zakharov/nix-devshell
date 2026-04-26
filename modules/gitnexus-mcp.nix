{ pkgs }:

{
  # This module depends on devshell.modules.gitnexus (add both in extraModules)

  shellHook = ''
    # === Declarative GitNexus MCP server (project-isolated) ===
    MCP_DIR="$PWD/.gitnexus/mcp"
    mkdir -p "$MCP_DIR"

    PID_FILE="$MCP_DIR/pid"
    LOG_FILE="$MCP_DIR/server.log"

    # Start MCP server only if not already running
    if [ ! -f "$PID_FILE" ] || ! kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "→ Starting GitNexus MCP server (background)..."
      mkdir -p "$MCP_DIR"

      # Run in background, detached from shell
      nohup gitnexus mcp > "$LOG_FILE" 2>&1 &
      echo $! > "$PID_FILE"

      echo "✅ GitNexus MCP server started (PID $(cat "$PID_FILE"))"
      echo "   Log: $LOG_FILE"
      echo "   Use in Claude Code / Cursor with MCP URL from gitnexus mcp output"
    else
      echo "✅ GitNexus MCP server already running (PID $(cat "$PID_FILE"))"
    fi

    # Optional helper aliases
    alias gitnexus-mcp-stop='[ -f "$PID_FILE" ] && kill "$(cat "$PID_FILE")" && rm -f "$PID_FILE" && echo "MCP server stopped"'
    alias gitnexus-mcp-log='tail -f "$LOG_FILE"'
  '';
}
