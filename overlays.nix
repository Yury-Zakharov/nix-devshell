# Single declaration site for all overlays.
# One owner: this file.

[
  (import ./overlays/spec-kit.nix)
  (import ./overlays/get-shit-done.nix)
  (import ./overlays/swarmvault.nix)
  (import ./overlays/gsd.nix)
  (import ./overlays/bmad-method.nix)
  (import ./overlays/gitnexus.nix)
  # Future shared overlays go here only
]
