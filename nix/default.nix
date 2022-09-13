# https://github.com/nmattia/niv
{ sources ? import ./sources.nix
, nixpkgs ? sources."nixpkgs-22.05"
}:

let

  overlay = _: pkgs: {
    # Patch Python distribution to base on setuptools 51.3.3, which is
    # the good known version of setuptools for zc.buildout
    python3 = pkgs.python3.override {
      packageOverrides = self: super: {
        zc_buildout_nix = self.callPackage ./pkgs/buildout {
          inherit (super)
          buildPythonPackage
          fetchPypi;
        };
      };
    };
  };

  pkgs = import nixpkgs {
    overlays = [ overlay ];
    config = {
    };
  };

in pkgs
