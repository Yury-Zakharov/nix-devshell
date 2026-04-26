{ pkgs }:

{
  packages = [
    pkgs.gitnexus
  ];

  shellHook = ''
    echo "GitNexus: $(gitnexus --version 2>/dev/null || echo "not found")"
    echo "GitNexus state & knowledge graph: fully isolated in ./.gitnexus/ (project root)"
    echo ""
    echo "Common commands:"
    echo "  gitnexus analyze              # build/update knowledge graph"
    echo "  gitnexus analyze --skills     # generate SKILL.md files"
    echo "  gitnexus mcp                  # start MCP server for Claude Code / Cursor"
    echo "  gitnexus serve                # start local web UI bridge"
  '';
}
