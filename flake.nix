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
        emacsOsxMaster = pkgs.emacsOsx.master.interp.default;
        emacsOsxNativeMaster = pkgs.emacsOsx.master.native.default;
        emacsOsxTileMaster = pkgs.emacsOsx.master.interp.tile;
        emacsOsxTileNativeMaster = pkgs.emacsOsx.master.native.tile;

        emacsOsxRelease = pkgs.emacsOsx.release.interp.default;
        emacsOsxNativeRelease = pkgs.emacsOsx.release.native.default;
        emacsOsxTileRelease = pkgs.emacsOsx.release.interp.tile;
        emacsOsxTileNativeRelease = pkgs.emacsOsx.release.native.tile;
      };
    });
}
