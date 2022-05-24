{ nixpkgs ? import <nixpkgs> { } }:
let pkgs = {
  atomi = (
    with import (fetchTarball "https://github.com/kirinnee/test-nix-repo/archive/v8.1.0.tar.gz");
    {
      inherit pls;
    }
  );
  "Unstable 25th Janurary 2021" = (
    with import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/2d77d1ce9018.tar.gz") { };
    {
      inherit
        terraform
        pre-commit
        nixpkgs-fmt
        coreutils
        git
        shfmt
        docker
        shellcheck
        ansible-lint
        hadolint;
      prettier = nodePackages.prettier;
    }
  );
}; in
with pkgs;
pkgs.atomi // pkgs."Unstable 25th Janurary 2021"
