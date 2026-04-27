{ pkgs }:

{
  packages = [
    pkgs.dotnet-sdk_10
  ];

  env = {
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    TESTCONTAINERS_RYUK_DISABLED = "true";

    # Full isolation inside project root
    NUGET_PACKAGES = "$PWD/.nuget/packages";
    DOTNET_CLI_HOME = "$PWD/.dotnet";
    DOTNET_TOOLS_PATH = "$PWD/.dotnet/tools";
    PATH = "$DOTNET_TOOLS_PATH:$PATH";
  };

  shellHook = ''
    # Explicit directory creation
    mkdir -p "$NUGET_PACKAGES" "$DOTNET_CLI_HOME/.templateengine/packages" "$DOTNET_CLI_HOME/tools"

    # === Declarative .NET local tools (including MCP servers) ===
    echo "→ Ensuring .NET local tools (including MCP servers)..."

    # NuGet MCP Server
    dotnet tool install --local NuGet.Mcp.Server --version 1.3.4 2>/dev/null || true

    # Roslyn MCP Server (best for C# structural awareness)
    dotnet tool install --local RoslynMcp.Server 2>/dev/null || true

    # Project-local NuGet.Config
    if [ ! -f "$PWD/NuGet.Config" ]; then
      cat > "$PWD/NuGet.Config" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <config>
    <add key="globalPackagesFolder" value=".nuget/packages" />
  </config>
  <packageSources>
    <clear />
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" />
    <add key="github" value="https://nuget.pkg.github.com/Yury-Zakharov/index.json" />
  </packageSources>
</configuration>
EOF
    fi

    echo "✅ Dotnet fully isolated with NuGet.Mcp.Server and RoslynMcp.Server"
    echo "   Tools: .config/dotnet-tools.json"
  '';
}
