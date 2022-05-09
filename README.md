nix-shell for `zc.buildout`
===========================

NixOS comes with patched buildout `zc-buildout-nix`, which will run buidout preferring Python packages available in the current nix-built Python environment.

Unfortunately, in time of writing, `zc.buildout` requires `setuptools <= 53.1.1` no longer the default `setuptools` in NixOS.

Therefore this environment.

