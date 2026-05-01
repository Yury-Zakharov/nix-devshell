{ pkgs }:

{
  shellHook = ''
    echo "Git worktree helpers available (wt-* commands)"

    alias wt-list="git worktree list"
    alias wt-prune="git worktree prune"

    # Create worktree for any branch
    # Usage: wt-create <branch-name> [worktree-name]
    wt-create() {
      local branch="$1"
      local name="''${2:-$(basename "$(pwd)")-$branch}"
      local worktree="../$name"

      [ -z "$branch" ] && { echo "Usage: wt-create <branch-name> [worktree-name]"; return 1; }

      [ -d "$worktree" ] && { echo "Worktree already exists: $worktree"; return 0; }

      echo "→ Creating worktree for branch '$branch' at $worktree"
      git worktree add "$worktree" "$branch" 2>/dev/null || git worktree add "$worktree" -b "$branch"
      echo "✓ Worktree ready → cd $worktree"
    }

    # Convenience: create worktree for spec-kit phase (optional)
    # Usage: wt-phase <phase-number>
    wt-phase() {
      local num="$1"
      [ -z "$num" ] && { echo "Usage: wt-phase <phase-number> (e.g. 005)"; return 1; }
      local branch=$(git branch --list "feature/phase-$num-*" --format='%(refname:short)' | head -n1)
      [ -z "$branch" ] && { echo "No branch found for phase-$num"; return 1; }
      wt-create "$branch"
    }
  '';
}
