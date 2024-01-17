{
  description = "emacs-osx";

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: let
    emacs-overlay = import ./emacs-overlay.nix;
  in
    flake-utils.lib.eachDefaultSystem (system: let
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
