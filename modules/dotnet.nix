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

    # Make locally-installed tools available
    DOTNET_TOOLS_PATH = "$PWD/.dotnet/tools";
    PATH = "$DOTNET_TOOLS_PATH:$PATH";
  };

  shellHook = ''
    # Explicit directory creation
    mkdir -p "$NUGET_PACKAGES"
    mkdir -p "$DOTNET_CLI_HOME/.templateengine/packages"
    mkdir -p "$DOTNET_CLI_HOME/tools"

    # Project-local NuGet.Config with GitHub registry + no secrets
    if [ ! -f "$PWD/NuGet.Config" ]; then
      cat > "$PWD/NuGet.Config" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <config>
    <add key="globalPackagesFolder" value=".nuget/packages" />
  </config>
  <packageSources>
    <clear />
    <!-- Official NuGet.org (optional) -->
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" />

    <!-- Your GitHub Packages registry (single declaration site) -->
    <add key="github" value="https://nuget.pkg.github.com/Yury-Zakharov/index.json" />
  </packageSources>
</configuration>
EOF
      echo "✅ Created project-local NuGet.Config (GitHub registry added, no secrets)"
    fi

    echo "✅ Dotnet fully isolated"
    echo "   NuGet packages   → $NUGET_PACKAGES"
    echo "   Templates + CLI  → $DOTNET_CLI_HOME"
    echo "   Dotnet SDK: $(dotnet --version 2>/dev/null || echo "not found")"
  '';
}
