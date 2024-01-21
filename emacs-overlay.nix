{pkgs}: let
  inherit (pkgs) lib stdenv libgccjit;

  # Original comment:
  # # I am using the "builder" from nix-community's emacs-overlay, with some slight modifications
  # # https://github.com/nix-community/emacs-overlay/blob/d1fbf6d39f3a0869c5fb0cc7f9ba7c9033e35cf9/default.nix#L25
  # I've continued to mess with it.
  mkGitEmacs = namePrefix: jsonFile: patches: {withNativeCompilation ? false, ...} @ args: let
    repoMeta = pkgs.lib.importJSON jsonFile;
    fetcher =
      if repoMeta.type == "savannah"
      then pkgs.fetchFromSavannah
      else if repoMeta.type == "github"
      then pkgs.fetchFromGitHub
      else throw "Unknown repository type ${repoMeta.type}!";
  in
    builtins.foldl' (drv: fn: fn drv) pkgs.emacs [
      (drv: drv.override ({srcRepo = true;} // args))

      # in order for this build to be differentiated from original `nixpkgs.emacs`
      (drv:
        drv.overrideAttrs (prev: {
          name = "${namePrefix}-${repoMeta.version}";
          inherit (repoMeta) version;
          patches =
            patches
            ++ lib.optionals withNativeCompilation [
              (pkgs.substituteAll {
                src = ./patches/native-comp-driver-options.patch;
                backendPath =
                  lib.concatStringsSep " "
                  (builtins.map (x: ''"-B${x}"'') ([
                      # Paths necessary so the JIT compiler finds its libraries:
                      "${lib.getLib libgccjit}/lib"
                      "${lib.getLib libgccjit}/lib/gcc"
                      "${lib.getLib stdenv.cc.libc}/lib"
                    ]
                    ++ lib.optionals (stdenv.cc ? cc.libgcc) [
                      "${lib.getLib stdenv.cc.cc.libgcc}/lib"
                    ]
                    ++ [
                      # Executable paths necessary for compilation (ld, as):
                      "${lib.getBin stdenv.cc.cc}/bin"
                      "${lib.getBin stdenv.cc.bintools}/bin"
                      "${lib.getBin stdenv.cc.bintools.bintools}/bin"
                    ]));
              })
            ];
          src = fetcher (builtins.removeAttrs repoMeta ["type" "version"]);
          postPatch =
            prev.postPatch
            + ''
              substituteInPlace lisp/loadup.el \
              --replace '(emacs-repository-get-version)' '"${repoMeta.rev}"' \
              --replace '(emacs-repository-get-branch)' '"master"'
            '';
          # https://github.com/NixOS/nixpkgs/issues/109997#issuecomment-867318377
          CFLAGS = "-DMAC_OS_X_VERSION_MAX_ALLOWED=110200 -g -O2";
        }))
    ];

  mkVersionSet = jsonFile: {
    interp.default = mkGitEmacs "emacs-osx" jsonFile [
      ./patches/codesign.patch
    ] {};

    native.default =
      mkGitEmacs "emacs-osx" jsonFile [
        ./patches/codesign.patch
      ] {
        withNativeCompilation = true;
      };

    # for use in chunwm or yabai
    interp.tile = mkGitEmacs "emacs-osx" jsonFile [
      ./patches/codesign.patch
      ./patches/fix-window-role-yabai.patch
    ] {};

    native.tile = mkGitEmacs "emacs-osx" jsonFile [
      ./patches/codesign.patch
      ./patches/fix-window-role-yabai.patch
    ] {withNativeCompilation = true;};
  };
in
  _: _: {
    emacsOsx = {
      master = mkVersionSet ./emacs-source/emacs-master.json;
      release = mkVersionSet ./emacs-source/emacs-release.json;
    };
  }
