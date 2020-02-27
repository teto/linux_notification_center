# from https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/haskell.section.md
{

  nixpkgs
  # ? import ./pinned_nixpkgs.nix
  ? import <nixpkgs> {}
  , compilerName ? "ghc865"
}:

let
  compiler = pkgs.haskell.packages."${compilerName}";
  pkgs = nixpkgs.pkgs;
  ghcide-nix = import (builtins.fetchTarball "https://github.com/hercules-ci/ghcide-nix/tarball/master") {};
  my_pkg = (import ./. );
in
  (my_pkg.envFunc { withHoogle = true; }).overrideAttrs (oa: {

    nativeBuildInputs = oa.nativeBuildInputs ++ (with pkgs; [

      # HASKELL IDE ENGINE
      haskellPackages.all-hies.versions."${compilerName}"

      # or ghcide
      ghcide-nix."ghcide-${compilerName}"

      haskellPackages.cabal-install
      haskellPackages.hasktags
      # haskellPackages.nvim-hs-ghcid # too old, won't support nvim-hs-contrib 2

      # haskellPackages.gutenhasktags  # taken from my overlay
      # haskellPackages.haskdogs # seems to build on hasktags/ recursively import things
    ]);

  # export HIE_HOOGLE_DATABASE=$NIX_GHC_DOCDIR as DOCDIR doesn't exist it won't work
  # or an interesting
  # shellHook = "eval $(grep export ${ghc}/bin/ghc)";
  # echo "importing a custom nvim ${my_nvim}"
  # export PATH="${my_nvim}/bin:$PATH"
  shellHook = ''
    # check if it's still needed ?
    export HIE_HOOGLE_DATABASE="$NIX_GHC_LIBDIR/../../share/doc/hoogle/index.html"
    echo "cabal clean"
    echo "cabal configure --extra-include-dirs=/home/teto/mptcp/build/usr/include -v3"
    echo "to run the daemon "
    echo "buildNrun"
  '';


  })
