{ pkgs }:

{
  packages = [ pkgs.swarmvault ];

  env = { };

  shellHook = ''
    echo "SwarmVault: $(swarmvault --version 2>/dev/null || echo "not found")"
    echo "All files (including node_modules) in ./swarmvault/"
    echo "Update: rm -rf .swarmvault && swarmvault --version"
    echo "MCP: swarmvault mcp"
  '';
}
