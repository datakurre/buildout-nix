{ pkgs ? import ./nix {}
}:

with pkgs;

mkShell {
  buildInputs = [
    black
    (python2.withPackages(ps: with ps; [
      # Packages that need to come from nixpkgs
      cryptography
      lxml
      pillow
      setuptools
      # AND
      zc_buildout_nix
    ]))
    pcre
  ];
}

