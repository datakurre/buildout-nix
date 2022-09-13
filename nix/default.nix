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
        zc_buildout_nix = super.zc_buildout_nix.overridePythonAttrs(old: rec {
          pname = "zc.buildout";
          version = "2.13.7";
          src = self.fetchPypi {
            inherit pname version;
            sha256 = "sha256-4S/jrfLmD1LamMjbRjBoi5TLGq1GayxqSm4P5A6o+Uo=";
          };
          postInstall = null;
          postPatch = ''
            # https://github.com/buildout/buildout/commit/2b6995c675bce0b5db12088d26dc7ea6e4b177b3
            substituteInPlace src/zc/buildout/buildout.py --replace "'38', '39'" "'38', '39', '310'"
          '';
        });
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
