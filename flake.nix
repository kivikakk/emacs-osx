{
  description = "emacs-osx";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.11;
    flake-utils.url = github:numtide/flake-utils;
  };

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
        emacsOsxMasterTile = pkgs.emacsOsx.master.interp.tile;
        emacsOsxMasterNative = pkgs.emacsOsx.master.native.default;
        emacsOsxMasterNativeTile = pkgs.emacsOsx.master.native.tile;

        emacsOsxRelease = pkgs.emacsOsx.release.interp.default;
        emacsOsxReleaseTile = pkgs.emacsOsx.release.interp.tile;
        emacsOsxReleaseNative = pkgs.emacsOsx.release.native.default;
        emacsOsxReleaseNativeTile = pkgs.emacsOsx.release.native.tile;
      };
    });
}
