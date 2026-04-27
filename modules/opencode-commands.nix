{ pkgs }:

{
  shellHook = ''
    # OpenCode common workflows (declarative aliases)
    alias oc='opencode'
    alias oc-plan='opencode plan'
    alias oc-implement='opencode implement'
    alias oc-review='opencode review'
    alias oc-debug='opencode debug'

    echo "OpenCode commands ready:"
    echo "  oc-plan        → create detailed plan"
    echo "  oc-implement   → implement current task"
    echo "  oc-review      → code review current changes"
    echo "  oc-debug       → debug current error"
  '';
}
