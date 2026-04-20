# Single declaration site for all overlays.
# One owner: this file.

[
  (import ./overlays/spec-kit.nix)
  (import ./overlays/get-shit-done.nix)
  (import ./overlays/swarmvault.nix)
  # Future shared overlays go here only
]
