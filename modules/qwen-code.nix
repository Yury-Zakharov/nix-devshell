{ pkgs }:

{
  packages = [
    pkgs.qwen-code
  ];

  env = {
    # Qwen Code supports system/user settings paths via env vars
    QWEN_CODE_SYSTEM_SETTINGS_PATH = "$XDG_CONFIG_HOME/.qwen/settings.json";
    QWEN_CODE_SYSTEM_DEFAULTS_PATH = "$XDG_CONFIG_HOME/.qwen/system-defaults.json";
  };

  shellHook = ''
    mkdir -p "$XDG_CONFIG_HOME/.qwen"

    echo "Qwen Code: $(qwen-code --version 2>/dev/null || true)"
    echo "Qwen Code config: redirected to \$XDG_CONFIG_HOME/.qwen"
  '';
}
