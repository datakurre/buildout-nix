{ pkgs ? import ./nix {}
, unstable ? import (import ./nix/sources.nix)."nixpkgs-unstable" {}
}:

with pkgs;

mkShell {
  buildInputs = [
    (python2.withPackages(ps: with ps; [
      # Packages that need to come from nixpkgs
      cryptography
      lxml
      pillow
      setuptools
      ldap
      idna
      requests
      magic
      # AND
      zc_buildout_nix
    ]))
    pcre
    jetbrains.pycharm-professional
    (unstable.vscode-with-extensions.override {
      vscode = unstable.vscodium;
      vscodeExtensions = with unstable.vscode-extensions; [
        github.copilot
        bbenoist.nix
        ms-python.python
        ms-python.vscode-pylance
        ms-vscode.makefile-tools
        vscodevim.vim
        (unstable.vscode-utils.buildVscodeMarketplaceExtension rec {
          mktplcRef = {
            name = "ruff";
            publisher = "charliermarsh";
            version = "2023.9.10740409";
            sha256 = "sha256-nXjeu6epOKoJoM0GpXjRSUWd5dN+bYP+cCgLY7s6oFU=";
          };
          postInstall = ''
rm -f $out/share/vscode/extensions/charliermarsh.ruff/bundled/libs/bin/ruff
ln -s ${unstable.ruff}/bin/ruff $out/share/vscode/extensions/charliermarsh.ruff/bundled/libs/bin/ruff
'';
        })
      ];
    })
  ];
}

