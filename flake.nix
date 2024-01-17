{
  description = "emacs-osx";

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs-pre = import nixpkgs {inherit system;};
      emacs-overlay = import ./emacs-overlay.nix {pkgs = pkgs-pre;};
      pkgs = import nixpkgs {
        inherit system;
        overlays = [emacs-overlay];
      };
    in {
      formatter = pkgs.alejandra;

      packages = {
        inherit
          (pkgs)
          emacsOsx
          emacsOsxNative
          emacsOsxTile
          emacsOsxNativeTile
          ;
      };
    });
}
