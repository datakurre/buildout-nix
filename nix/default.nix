# https://github.com/nmattia/niv
{ sources ? import ./sources.nix
, nixpkgs ? sources."nixpkgs-21.11"
}:

let

  overlay = _: pkgs: {
    # Patch Python distribution to base on setuptools 51.3.3, which is
    # the good known version of setuptools for zc.buildout
    python3 = pkgs.python3.override {
      packageOverrides = self: super: {
        bootstrapped-pip = self.callPackage ./pkgs/bootstrapped-pip {
          inherit (self)
          setuptools;
          inherit (super)
          pip
          pipInstallHook
          python
          setuptoolsBuildHook
          wheel;
        };
        setuptools = pkgs.callPackage ./pkgs/setuptools {
          inherit (self)
          bootstrapped-pip;
          inherit (super)
          buildPythonPackage
          pipInstallHook
          python
          setuptoolsBuildHook
          wrapPython;
        };
        # override required to avoid conflicting paths
        pytestCheckHook = super.pytestCheckHook.override { pytest = self.pytest; };
        # Plone pins
        cryptography = self.callPackage ./pkgs/cryptography {
          inherit (super)
          buildPythonPackage
          Security;
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
