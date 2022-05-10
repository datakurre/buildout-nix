{ pkgs ? import ./nix {}
}:

with pkgs;

mkShell {
  buildInputs = [
    black
    (python3.withPackages(ps: with ps; [
      # Packages that need to come from nixpkgs
      cryptography
      lxml
      pillow
      setuptools
      # AND
      tox
      zc_buildout_nix
    ]))
    pcre
  ];
}

