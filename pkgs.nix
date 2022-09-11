let
  # refer https://status.nixos.org for latest nixpkgs
  commit = "17352e8995e1409636b0817a7f38d6314ccd73c4";
  pkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${commit}.tar.gz";

    # nix-prefetch-url --unpack \
    # https://github.com/NixOS/nixpkgs/archive/b2d256095aeac09f8af6b6c95ab3cf4bc5fd4e6f.tar.gz
    sha256 = "1cb9p9hfbwwnjaxqxh1fammq9hcrm2qghqyjzvprrk1vcq7dzhxc";
  }) { overlays = [ (import ./emacs-overlay.nix) ]; };
in pkgs
