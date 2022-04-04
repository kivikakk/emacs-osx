let
  # refer https://status.nixos.org for latest nixpkgs
  commit = "30d3d79b7d3607d56546dd2a6b49e156ba0ec634";
  pkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${commit}.tar.gz";

    # nix-prefetch-url --unpack \
    # https://github.com/NixOS/nixpkgs/archive/b2d256095aeac09f8af6b6c95ab3cf4bc5fd4e6f.tar.gz
    sha256 = "sha256:0x5j9q1vi00c6kavnjlrwl3yy1xs60c34pkygm49dld2sgws7n0a";
  }) { overlays = [ (import ./emacs-overlay.nix) ]; };
in pkgs
